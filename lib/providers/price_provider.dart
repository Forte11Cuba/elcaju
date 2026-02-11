import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/price_service.dart';

/// Provider para manejar precios de BTC con caché
class PriceProvider extends ChangeNotifier {
  /// Precio de BTC en USD (caché)
  double? _btcPriceUsd;

  /// Precio de BTC en EUR (caché)
  double? _btcPriceEur;

  /// Timestamp de última actualización
  DateTime? _lastUpdate;

  /// Intervalo mínimo entre actualizaciones (60 segundos)
  static const _minRefreshInterval = Duration(seconds: 60);

  /// Timer para refresh automático
  Timer? _refreshTimer;

  /// Error de última operación
  String? _error;

  /// Getters
  double? get btcPriceUsd => _btcPriceUsd;
  double? get btcPriceEur => _btcPriceEur;
  DateTime? get lastUpdate => _lastUpdate;
  String? get error => _error;
  bool get hasPrice => _btcPriceUsd != null;

  /// Obtiene el precio de BTC para una moneda específica
  double? getBtcPrice(String currency) {
    switch (currency.toLowerCase()) {
      case 'usd':
        return _btcPriceUsd;
      case 'eur':
        return _btcPriceEur;
      default:
        return null;
    }
  }

  /// Verifica si necesita actualizar el precio
  bool get _needsRefresh {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > _minRefreshInterval;
  }

  /// Inicializa el provider y comienza refresh automático
  Future<void> initialize() async {
    await refreshPrices();
    _startAutoRefresh();
  }

  /// Inicia el timer de refresh automático
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_minRefreshInterval, (_) {
      refreshPrices();
    });
  }

  /// Actualiza los precios desde la API
  Future<void> refreshPrices() async {
    if (!_needsRefresh && _btcPriceUsd != null) return;

    try {
      _error = null;

      // Obtener precio USD
      _btcPriceUsd = await PriceService.getBtcPrice('USD');

      // Intentar obtener EUR también
      try {
        _btcPriceEur = await PriceService.getBtcPrice('EUR');
      } catch (_) {
        // EUR es opcional
      }

      _lastUpdate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Convierte cantidad en unidad fiat (centavos) a sats
  /// Usa caché si está disponible, sino llama a la API
  Future<BigInt> fiatCentsToSats(BigInt cents, String fiatCurrency) async {
    final btcPrice = getBtcPrice(fiatCurrency);

    if (btcPrice != null) {
      // Usar precio cacheado
      final fiatAmount = cents.toDouble() / 100;
      final btcAmount = fiatAmount / btcPrice;
      final sats = (btcAmount * 100000000).round();
      return BigInt.from(sats);
    }

    // Fallback a API directa
    return PriceService.fiatCentsToSats(cents, fiatCurrency);
  }

  /// Convierte sats a cantidad en unidad fiat (centavos)
  Future<BigInt> satsToFiatCents(BigInt sats, String fiatCurrency) async {
    final btcPrice = getBtcPrice(fiatCurrency);

    if (btcPrice != null) {
      // Usar precio cacheado
      final btcAmount = sats.toDouble() / 100000000;
      final fiatAmount = btcAmount * btcPrice;
      return BigInt.from((fiatAmount * 100).round());
    }

    // Fallback a API directa
    return PriceService.satsToFiatCents(sats, fiatCurrency);
  }

  /// Formatea el precio para display
  String formatBtcPrice(String currency) {
    final price = getBtcPrice(currency);
    if (price == null) return '--';

    // Formatear con separador de miles
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
