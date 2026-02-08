// Parser para detectar el tipo de dato entrante (QR, clipboard, etc.)
// Soporta: tokens Cashu (A/B), invoices Lightning, URLs de mint, payment requests

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

    // Invoice Lightning (lnbc..., lntb..., lnbcrt...)
    if (lower.startsWith('lnbc') ||
        lower.startsWith('lntb') ||
        lower.startsWith('lnbcrt') ||
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

    // URL de mint (https://...)
    if (lower.startsWith('https://')) {
      // Verificar si parece una URL de mint (heurística simple)
      // Los mints típicos tienen /v1/info o son URLs simples
      return ParsedData(
        type: IncomingDataType.mintUrl,
        raw: trimmed,
        mintUrl: trimmed,
      );
    }

    // Tipo desconocido
    return ParsedData(
      type: IncomingDataType.unknown,
      raw: trimmed,
    );
  }

  /// Verifica si el dato es un fragmento UR
  static bool isUrFragment(String data) {
    return data.toLowerCase().startsWith('ur:');
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

/// Modo de escaneo
enum ScanMode {
  any,          // Desde HomeScreen - detecta y navega automáticamente
  cashuOnly,    // Desde ReceiveScreen - solo acepta tokens Cashu
  invoiceOnly,  // Desde MeltScreen - solo acepta invoices Lightning
}
