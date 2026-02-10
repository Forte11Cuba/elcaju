import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para obtener precios de Bitcoin usando Yadio API
class PriceService {
  static const _baseUrl = 'https://api.yadio.io';
  static const _timeout = Duration(seconds: 10);

  /// Obtiene el precio de BTC en una moneda fiat (USD, EUR, etc.)
  /// Retorna el precio de 1 BTC en la moneda especificada
  static Future<double> getBtcPrice(String currency) async {
    try {
      // /rate/{quote}/{base} - retorna cuánto del quote por 1 base
      // /rate/USD/BTC retorna cuántos USD por 1 BTC
      final response = await http.get(
        Uri.parse('$_baseUrl/rate/${currency.toUpperCase()}/BTC'),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rate = json['rate'];

      if (rate == null) {
        throw Exception('Precio no disponible');
      }

      return (rate as num).toDouble();
    } catch (e) {
      throw Exception('Error obteniendo precio BTC: $e');
    }
  }

  /// Convierte una cantidad de una moneda a otra
  /// Ejemplo: convert(2.50, 'USD', 'BTC') -> 0.0000244
  static Future<double> convert(double amount, String from, String to) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/convert/$amount/${from.toUpperCase()}/${to.toUpperCase()}'),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Error HTTP: ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json['result'];

      if (result == null) {
        throw Exception('Conversión no disponible');
      }

      return (result as num).toDouble();
    } catch (e) {
      throw Exception('Error en conversión: $e');
    }
  }

  /// Convierte cantidad en unidad fiat (centavos) a sats
  /// Ejemplo: 250 cents USD -> X sats
  static Future<BigInt> fiatCentsToSats(BigInt cents, String fiatCurrency) async {
    // Convertir centavos a unidad mayor (ej: 250 cents -> 2.50 USD)
    final fiatAmount = cents.toDouble() / 100;

    // Obtener precio BTC en fiat
    final btcPrice = await getBtcPrice(fiatCurrency);

    // Calcular BTC y luego sats
    final btcAmount = fiatAmount / btcPrice;
    final sats = (btcAmount * 100000000).round();

    return BigInt.from(sats);
  }

  /// Convierte sats a cantidad en unidad fiat (centavos)
  static Future<BigInt> satsToFiatCents(BigInt sats, String fiatCurrency) async {
    // Obtener precio BTC en fiat
    final btcPrice = await getBtcPrice(fiatCurrency);

    // Calcular fiat amount
    final btcAmount = sats.toDouble() / 100000000;
    final fiatAmount = btcAmount * btcPrice;

    // Retornar en centavos
    return BigInt.from((fiatAmount * 100).round());
  }
}
