import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bech32/bech32.dart';

/// Tipo de input detectado
enum LnInputType {
  bolt11Invoice,    // lnbc..., lntb..., lnbcrt...
  lnurl,            // lnurl1...
  lightningAddress, // user@domain.com
  unknown,
}

/// Parámetros de LNURL-pay
class LnurlPayParams {
  final String callback;
  final BigInt minSendable;  // millisats
  final BigInt maxSendable;  // millisats
  final String? metadata;
  final String? description;
  final String? domain;

  LnurlPayParams({
    required this.callback,
    required this.minSendable,
    required this.maxSendable,
    this.metadata,
    this.description,
    this.domain,
  });

  /// Monto mínimo en sats
  BigInt get minSats => minSendable ~/ BigInt.from(1000);

  /// Monto máximo en sats
  BigInt get maxSats => maxSendable ~/ BigInt.from(1000);

  /// Verifica si un monto (en sats) está dentro del rango permitido
  bool isAmountValid(BigInt amountSats) {
    final amountMsats = amountSats * BigInt.from(1000);
    return amountMsats >= minSendable && amountMsats <= maxSendable;
  }
}

/// Resultado de obtener invoice desde LNURL
class LnurlInvoiceResult {
  final String invoice;
  final String? successAction;

  LnurlInvoiceResult({
    required this.invoice,
    this.successAction,
  });
}

/// Servicio para resolver LNURL y Lightning Address
class LnurlService {
  static const _timeout = Duration(seconds: 10);

  /// Detecta el tipo de input
  static LnInputType detectType(String input) {
    final trimmed = input.trim();
    final lower = trimmed.toLowerCase();

    // Invoice BOLT11
    if (lower.startsWith('lnbc') ||
        lower.startsWith('lntb') ||
        lower.startsWith('lnbcrt') ||
        lower.startsWith('lightning:lnbc') ||
        lower.startsWith('lightning:lntb') ||
        lower.startsWith('lightning:lnbcrt')) {
      return LnInputType.bolt11Invoice;
    }

    // LNURL
    if (lower.startsWith('lnurl1') ||
        lower.startsWith('lightning:lnurl1')) {
      return LnInputType.lnurl;
    }

    // Lightning Address (user@domain.com)
    if (_isLightningAddress(trimmed)) {
      return LnInputType.lightningAddress;
    }

    return LnInputType.unknown;
  }

  /// Verifica si es una Lightning Address válida
  static bool _isLightningAddress(String input) {
    // Formato: user@domain.com
    if (!input.contains('@')) return false;

    final parts = input.split('@');
    if (parts.length != 2) return false;

    final user = parts[0];
    final domain = parts[1];

    // Validación básica
    if (user.isEmpty || domain.isEmpty) return false;
    if (!domain.contains('.')) return false;

    // No debe tener espacios
    if (user.contains(' ') || domain.contains(' ')) return false;

    return true;
  }

  /// Limpia el input removiendo prefijos
  static String cleanInput(String input) {
    var cleaned = input.trim();

    // Remover prefijo lightning:
    if (cleaned.toLowerCase().startsWith('lightning:')) {
      cleaned = cleaned.substring(10);
    }

    return cleaned;
  }

  /// Decodifica LNURL (bech32) a URL
  static String? decodeLnurl(String lnurl) {
    try {
      final cleaned = cleanInput(lnurl).toLowerCase();
      final decoded = const Bech32Codec().decode(cleaned);

      if (decoded.hrp != 'lnurl') return null;

      // Convertir de 5-bit a 8-bit
      final bytes = _convertBits(decoded.data, 5, 8, false);
      return utf8.decode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Convierte bits (usado para decodificar bech32)
  static List<int> _convertBits(List<int> data, int fromBits, int toBits, bool pad) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << toBits) - 1;

    for (final value in data) {
      acc = (acc << fromBits) | value;
      bits += fromBits;
      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & maxv);
      }
    }

    if (pad && bits > 0) {
      result.add((acc << (toBits - bits)) & maxv);
    } else if (!pad && (bits >= fromBits || ((acc << (toBits - bits)) & maxv) != 0)) {
      throw FormatException('Invalid padding in bech32 conversion');
    }

    return result;
  }

  /// Resuelve LNURL a parámetros de pago
  static Future<LnurlPayParams> resolveLnurl(String lnurl) async {
    final url = decodeLnurl(lnurl);
    if (url == null) {
      throw Exception('LNURL inválido');
    }

    return _fetchLnurlPayParams(url);
  }

  /// Resuelve Lightning Address a parámetros de pago
  static Future<LnurlPayParams> resolveLightningAddress(String address) async {
    final cleaned = cleanInput(address);
    final parts = cleaned.split('@');

    if (parts.length != 2) {
      throw Exception('Lightning Address inválida');
    }

    final user = parts[0];
    final domain = parts[1];

    // Construir URL .well-known/lnurlp
    final url = 'https://$domain/.well-known/lnurlp/$user';

    return _fetchLnurlPayParams(url, domain: domain);
  }

  /// Obtiene parámetros LNURL-pay desde URL
  static Future<LnurlPayParams> _fetchLnurlPayParams(String url, {String? domain}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Verificar errores
      if (json.containsKey('status') && json['status'] == 'ERROR') {
        throw Exception(json['reason'] ?? 'Error desconocido');
      }

      // Verificar que es LNURL-pay (tag = payRequest)
      final tag = json['tag'] as String?;
      if (tag != null && tag != 'payRequest') {
        throw Exception('No es LNURL-pay (tag: $tag)');
      }

      // Extraer parámetros
      final callback = json['callback'] as String?;
      if (callback == null || callback.isEmpty) {
        throw Exception('Respuesta LNURL-pay inválida: falta callback');
      }

      final minRaw = json['minSendable'] as num?;
      final maxRaw = json['maxSendable'] as num?;
      if (minRaw == null || maxRaw == null) {
        throw Exception('Respuesta LNURL-pay inválida: falta minSendable/maxSendable');
      }
      final minSendable = BigInt.from(minRaw.toInt());
      final maxSendable = BigInt.from(maxRaw.toInt());
      final metadata = json['metadata'] as String?;

      // Extraer descripción del metadata
      String? description;
      if (metadata != null) {
        try {
          final metadataList = jsonDecode(metadata) as List;
          for (final item in metadataList) {
            if (item is List && item.length >= 2 && item[0] == 'text/plain') {
              description = item[1] as String;
              break;
            }
          }
        } catch (_) {}
      }

      // Extraer dominio del callback si no se proporcionó
      final callbackUri = Uri.parse(callback);
      final effectiveDomain = domain ?? callbackUri.host;

      return LnurlPayParams(
        callback: callback,
        minSendable: minSendable,
        maxSendable: maxSendable,
        metadata: metadata,
        description: description,
        domain: effectiveDomain,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error resolviendo LNURL: $e');
    }
  }

  /// Obtiene invoice BOLT11 desde callback LNURL-pay
  static Future<LnurlInvoiceResult> fetchInvoice(
    String callback,
    BigInt amountSats,
  ) async {
    try {
      // Convertir a millisats
      final amountMsats = amountSats * BigInt.from(1000);

      // Construir URL con parámetros
      final uri = Uri.parse(callback);
      final queryParams = Map<String, String>.from(uri.queryParameters);
      queryParams['amount'] = amountMsats.toString();

      final requestUri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        requestUri,
        headers: {'Accept': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      // Verificar errores
      if (json.containsKey('status') && json['status'] == 'ERROR') {
        throw Exception(json['reason'] ?? 'Error obteniendo invoice');
      }

      // Extraer invoice
      final pr = json['pr'] as String?;
      if (pr == null || pr.isEmpty) {
        throw Exception('No se recibió invoice');
      }

      // Success action (opcional)
      String? successAction;
      if (json.containsKey('successAction')) {
        final sa = json['successAction'] as Map<String, dynamic>?;
        if (sa != null && sa['message'] != null) {
          successAction = sa['message'] as String;
        }
      }

      return LnurlInvoiceResult(
        invoice: pr,
        successAction: successAction,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error obteniendo invoice: $e');
    }
  }
}
