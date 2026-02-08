// Parser para detectar el tipo de dato entrante (QR, clipboard, etc.)
// Soporta: tokens Cashu (A/B), invoices Lightning, URLs de mint, payment requests

/// Modo de escaneo
enum ScanMode {
  any,          // Desde HomeScreen - detecta y navega automáticamente
  cashuOnly,    // Desde ReceiveScreen - solo acepta tokens Cashu
  invoiceOnly,  // Desde MeltScreen - solo acepta invoices Lightning
}

/// Tipo de dato detectado
enum IncomingDataType {
  cashuToken,       // cashuA... / cashuB...
  lightningInvoice, // lnbc... / lntb... / lnbcrt...
  mintUrl,          // https://...
  paymentRequest,   // creqA... (post-MVP, Cashu payment request)
  unknown,
}

/// Información de un token parseado (para preview)
class TokenInfo {
  final BigInt amount;
  final String mintUrl;
  final String? unit;
  final String? memo;

  TokenInfo({
    required this.amount,
    required this.mintUrl,
    this.unit,
    this.memo,
  });
}

/// Resultado del parsing
class ParsedData {
  final IncomingDataType type;
  final String raw;
  final TokenInfo? tokenInfo;
  final String? invoiceBolt11;
  final String? mintUrl;

  ParsedData({
    required this.type,
    required this.raw,
    this.tokenInfo,
    this.invoiceBolt11,
    this.mintUrl,
  });

  /// True si el tipo es conocido y puede ser procesado
  bool get isValid => type != IncomingDataType.unknown;
}

/// Parser estático para detectar tipo de dato
class IncomingDataParser {
  /// Detecta el tipo de dato y extrae información relevante
  static ParsedData parse(String data) {
    final trimmed = data.trim();
    final lower = trimmed.toLowerCase();

    // Token Cashu (cashuA... o cashuB...)
    if (lower.startsWith('cashua') || lower.startsWith('cashub')) {
      return ParsedData(
        type: IncomingDataType.cashuToken,
        raw: trimmed,
      );
    }

    // UR encoded token (ur:cashu/...)
    if (lower.startsWith('ur:cashu')) {
      return ParsedData(
        type: IncomingDataType.cashuToken,
        raw: trimmed,
      );
    }

    // Invoice Lightning (lnbcrt..., lnbc..., lntb...)
    // Nota: lnbcrt debe ir primero porque lnbc es prefijo de lnbcrt
    if (lower.startsWith('lnbcrt') ||
        lower.startsWith('lnbc') ||
        lower.startsWith('lntb') ||
        lower.startsWith('lightning:')) {
      // Remover prefijo lightning: si existe
      final invoice = lower.startsWith('lightning:')
          ? trimmed.substring(10)
          : trimmed;
      return ParsedData(
        type: IncomingDataType.lightningInvoice,
        raw: trimmed,
        invoiceBolt11: invoice,
      );
    }

    // Payment Request (creqA...)
    if (lower.startsWith('creqa')) {
      return ParsedData(
        type: IncomingDataType.paymentRequest,
        raw: trimmed,
      );
    }

    // URL potencial de mint (https://...)
    if (lower.startsWith('https://')) {
      try {
        final uri = Uri.parse(trimmed);
        final path = uri.path.toLowerCase();

        // Solo clasificar como mint si tiene endpoints conocidos de Cashu
        // o es una URL limpia (sin path o solo /)
        final isMintEndpoint = path.contains('/v1/info') ||
            path.contains('/v1/keys') ||
            path.contains('/v1/mint') ||
            path.contains('/v1/melt');
        final isCleanUrl = path.isEmpty || path == '/';

        if (isMintEndpoint || isCleanUrl) {
          // Normalizar: quitar trailing slash y paths de API
          String mintUrl = '${uri.scheme}://${uri.host}';
          if (uri.port != 443) mintUrl += ':${uri.port}';

          return ParsedData(
            type: IncomingDataType.mintUrl,
            raw: trimmed,
            mintUrl: mintUrl,
          );
        }
        // URLs con paths no-mint (ej: /about, /login) → unknown
      } catch (_) {
        // URL malformada → unknown
      }
    }

    // Tipo desconocido
    return ParsedData(
      type: IncomingDataType.unknown,
      raw: trimmed,
    );
  }

  /// Verifica si el dato es un fragmento UR de Cashu
  /// Solo detectamos ur:cashu, otros tipos UR (ur:crypto-psbt, etc.) se ignoran
  static bool isUrFragment(String data) {
    return data.toLowerCase().startsWith('ur:cashu');
  }

  /// Extrae información del header UR (índice y total)
  /// Formato: ur:cashu/1-5/payload...
  /// Retorna (currentIndex, totalFragments) o null si no es válido
  static (int, int)? parseUrHeader(String data) {
    final lower = data.toLowerCase();
    if (!lower.startsWith('ur:')) return null;

    // Buscar el patrón X-Y después del tipo
    final parts = data.split('/');
    if (parts.length < 2) return null;

    // El segundo segmento debería ser "index-total" o solo el index si es único
    final indexPart = parts[1];

    // Verificar si es formato multipart (X-Y)
    if (indexPart.contains('-')) {
      final indices = indexPart.split('-');
      if (indices.length == 2) {
        final current = int.tryParse(indices[0]);
        final total = int.tryParse(indices[1]);
        if (current != null && total != null) {
          return (current, total);
        }
      }
    }

    return null;
  }

  /// Verifica si un dato es válido para un modo específico
  static bool isValidForMode(ParsedData data, ScanMode mode) {
    switch (mode) {
      case ScanMode.any:
        return data.type != IncomingDataType.unknown;
      case ScanMode.cashuOnly:
        return data.type == IncomingDataType.cashuToken;
      case ScanMode.invoiceOnly:
        return data.type == IncomingDataType.lightningInvoice;
    }
  }
}
