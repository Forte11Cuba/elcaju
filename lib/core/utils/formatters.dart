import 'package:intl/intl.dart';

/// Utilidades para formatear montos y unidades en El Caju.
///
/// USD y EUR usan centavos (multiplicador 100).
/// SAT y otras unidades usan valores enteros.

class UnitFormatter {
  /// Multiplicador para convertir a unidad base.
  /// USD/EUR almacenan centavos, display en unidades.
  static int getMultiplier(String unit) {
    switch (unit.toLowerCase()) {
      case 'usd':
      case 'eur':
        return 100; // centavos
      default:
        return 1;
    }
  }

  /// Formatea un balance para display.
  /// Ejemplo: 1000 sat → "1,000", 500 usd → "5.00"
  static String formatBalance(BigInt amount, String unit) {
    final multiplier = getMultiplier(unit);

    if (multiplier == 100) {
      // USD/EUR: mostrar con 2 decimales
      final value = amount.toDouble() / 100;
      return value.toStringAsFixed(2);
    } else {
      // SAT y otros: entero con separador de miles
      return NumberFormat('#,###').format(amount.toInt());
    }
  }

  /// Formatea un balance con su unidad.
  /// Ejemplo: 1000 sat → "1,000 sat", 500 usd → "5.00 USD"
  static String formatBalanceWithUnit(BigInt amount, String unit) {
    final formatted = formatBalance(amount, unit);
    final label = getUnitLabel(unit);
    return '$formatted $label';
  }

  /// Obtiene la etiqueta de display para una unidad (para balances).
  /// Siguiendo el estándar de cashu.me: minúsculas para sat/msat
  /// Ejemplo: "855 sat", "5.00 USD"
  static String getUnitLabel(String unit) {
    switch (unit.toLowerCase()) {
      case 'sat':
        return 'sat';
      case 'usd':
        return 'USD';
      case 'eur':
        return 'EUR';
      case 'msat':
        return 'msat';
      default:
        return unit;
    }
  }

  /// Obtiene la etiqueta para el botón toggle de unidad.
  /// sat → "BTC" (indica Bitcoin), otros → mayúsculas
  static String getToggleLabel(String unit) {
    switch (unit.toLowerCase()) {
      case 'sat':
        return 'BTC';
      case 'usd':
        return 'USD';
      case 'eur':
        return 'EUR';
      case 'msat':
        return 'mSAT';
      default:
        return unit.toUpperCase();
    }
  }

  /// Obtiene la etiqueta en mayúsculas (para badges, estados).
  /// Ejemplo: "PENDING: 536 SAT"
  static String getUnitLabelUppercase(String unit) {
    switch (unit.toLowerCase()) {
      case 'sat':
        return 'SAT';
      case 'usd':
        return 'USD';
      case 'eur':
        return 'EUR';
      case 'msat':
        return 'mSAT';
      default:
        return unit.toUpperCase();
    }
  }

  /// Convierte input del usuario a BigInt para la unidad.
  /// Ejemplo: "5.00" USD → BigInt(500)
  static BigInt parseUserInput(String input, String unit) {
    final multiplier = getMultiplier(unit);

    // Limpiar input
    final cleaned = input.replaceAll(',', '').replaceAll(' ', '');

    if (multiplier == 100) {
      // USD/EUR: parsear como decimal
      final value = double.tryParse(cleaned) ?? 0.0;
      return BigInt.from((value * 100).round());
    } else {
      // SAT: parsear como entero
      return BigInt.from(int.tryParse(cleaned) ?? 0);
    }
  }

  /// Obtiene el nombre del host de un mint URL.
  /// Ejemplo: 'https://mint.cubabitcoin.org' → 'cubabitcoin.org'
  static String getMintDisplayName(String mintUrl) {
    try {
      final uri = Uri.parse(mintUrl);
      var host = uri.host;

      // Limpiar prefijos comunes
      host = host.replaceFirst('mint.', '');
      host = host.replaceFirst('www.', '');

      return host;
    } catch (e) {
      return mintUrl;
    }
  }

  /// Formatea una fecha relativa.
  /// Ejemplo: hace 5 min, hace 2 h, ayer, 15 ene
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('d MMM').format(date);
    }
  }

  /// Convierte timestamp BigInt (unix seconds) a DateTime.
  static DateTime timestampToDateTime(BigInt timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(
      timestamp.toInt() * 1000,
    );
  }
}
