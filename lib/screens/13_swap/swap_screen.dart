import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/price_service.dart';
import '../../src/rust/api/wallet.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/price_provider.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen>
    with SingleTickerProviderStateMixin {
  // true = sats → usd, false = usd → sats
  bool _isSatsToUsd = true;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  // Cuál campo se editó último: true = from, false = to
  bool _lastEditedFrom = true;
  // Evita loops infinitos entre listeners
  bool _isUpdating = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  BigInt _satsBalance = BigInt.zero;
  BigInt _usdBalance = BigInt.zero;

  List<double> _chartData = [];
  bool _isLoadingChart = true;

  // --- Swap state ---
  bool _isSwapping = false;
  String? _swapError;
  // Suscripciones locales (NO usa los globales del provider)
  StreamSubscription<MintQuote>? _mintSubscription;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _fromController.addListener(_onFromChanged);
    _toController.addListener(_onToChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBalances();
      _loadChartData();
    });
  }

  @override
  void dispose() {
    _mintSubscription?.cancel();
    _fromController.dispose();
    _toController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = WalletProvider.cubaBitcoinMint;
    if (mintUrl == null) return;

    try {
      final balances = await walletProvider.getBalancesForMint(mintUrl);
      if (!mounted) return;
      setState(() {
        _satsBalance = balances['sat'] ?? BigInt.zero;
        _usdBalance = balances['usd'] ?? BigInt.zero;
      });
    } catch (e) {
      debugPrint('Error loading swap balances: $e');
    }
  }

  Future<void> _loadChartData() async {
    try {
      final prices = await PriceService.getHistoricalPrices(range: 'ONE_DAY');
      if (mounted && prices.isNotEmpty) {
        setState(() {
          _chartData = prices.map((p) => p.priceUsd).toList();
          _isLoadingChart = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _chartData = _generateMockData();
          _isLoadingChart = false;
        });
      }
    }
  }

  List<double> _generateMockData() {
    final priceProvider = context.read<PriceProvider>();
    final basePrice = priceProvider.btcPriceUsd ?? 65000;
    final rng = Random();
    return List.generate(24, (i) {
      return basePrice + (rng.nextDouble() - 0.48) * basePrice * 0.02;
    });
  }

  void _onFromChanged() {
    if (_isUpdating) return;
    _lastEditedFrom = true;
    _syncConversion(fromSource: true);
  }

  void _onToChanged() {
    if (_isUpdating) return;
    _lastEditedFrom = false;
    _syncConversion(fromSource: false);
  }

  /// Calcula el campo opuesto basado en el campo editado
  void _syncConversion({required bool fromSource}) {
    final source = fromSource ? _fromController : _toController;
    final target = fromSource ? _toController : _fromController;
    final text = source.text;

    if (text.isEmpty) {
      _isUpdating = true;
      target.text = '';
      _isUpdating = false;
      setState(() {});
      return;
    }

    final priceProvider = context.read<PriceProvider>();
    final btcPrice = priceProvider.btcPriceUsd;
    if (btcPrice == null || btcPrice == 0) return;

    try {
      // Determinar si el source es sats o usd
      final sourceIsSats =
          (fromSource && _isSatsToUsd) || (!fromSource && !_isSatsToUsd);

      String result;
      if (sourceIsSats) {
        final sats = int.tryParse(text) ?? 0;
        final usd = sats / 100000000 * btcPrice;
        result = usd == 0 ? '' : usd.toStringAsFixed(2);
      } else {
        final usd = double.tryParse(text) ?? 0;
        final sats = (usd / btcPrice * 100000000).round();
        result = sats == 0 ? '' : sats.toString();
      }

      _isUpdating = true;
      target.text = result;
      _isUpdating = false;
      setState(() {});
    } catch (_) {
      // ignorar errores de parseo parcial
    }
  }

  void _flipDirection() {
    HapticFeedback.mediumImpact();
    if (_isSatsToUsd) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }

    // Intercambiar valores entre campos
    final fromText = _fromController.text;
    final toText = _toController.text;

    _isUpdating = true;
    setState(() {
      _isSatsToUsd = !_isSatsToUsd;
      _fromController.text = toText;
      _toController.text = fromText;
      _lastEditedFrom = !_lastEditedFrom;
    });
    _isUpdating = false;
  }

  void _setMaxAmount() {
    if (_isSatsToUsd) {
      _fromController.text = _satsBalance.toString();
    } else {
      final usd = _usdBalance.toDouble() / 100;
      _fromController.text = usd.toStringAsFixed(2);
    }
    _lastEditedFrom = true;
  }

  // --- Validación de mínimos del mint ---
  static const double _minUsd = 0.01;
  static const int _minSats = 1;

  /// Valida que ambos lados cumplan los mínimos del mint.
  /// Retorna null si es válido, o el mensaje de error si no.
  String? _validateMinimums(L10n l10n) {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) return null;

    final priceProvider = context.read<PriceProvider>();
    final btcPrice = priceProvider.btcPriceUsd;
    if (btcPrice == null || btcPrice == 0) return null;

    if (_isSatsToUsd) {
      // from=sats, to=usd → verificar que USD >= 0.01
      final usd = double.tryParse(_toController.text) ?? 0;
      if (usd < _minUsd) {
        // Calcular mínimo de sats necesario
        final minSatsNeeded = ((_minUsd / btcPrice) * 100000000).ceil();
        return l10n.swapMinimum('$minSatsNeeded sats');
      }
    } else {
      // from=usd, to=sats → verificar que sats >= 1 y USD >= 0.01
      final usd = double.tryParse(_fromController.text) ?? 0;
      final sats = int.tryParse(_toController.text) ?? 0;
      if (usd < _minUsd) {
        return l10n.swapMinimum('\$${_minUsd.toStringAsFixed(2)}');
      }
      if (sats < _minSats) {
        return l10n.swapMinimum('$_minSats sat');
      }
    }
    return null;
  }

  // --- Swap logic ---

  /// Determina el monto destino en BigInt (centavos para USD, sats para sat).
  BigInt _getDestAmount() {
    final destText = _toController.text;
    final destUnit = _isSatsToUsd ? 'usd' : 'sat';
    return UnitFormatter.parseUserInput(destText, destUnit);
  }

  /// Determina unidades de origen y destino.
  String get _srcUnit => _isSatsToUsd ? 'sat' : 'usd';
  String get _destUnit => _isSatsToUsd ? 'usd' : 'sat';

  /// Inicia el swap: crea mint quote en destino, obtiene melt quote en origen,
  /// muestra fee en modal de confirmación.
  Future<void> _startSwap() async {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = WalletProvider.cubaBitcoinMint;
    if (mintUrl == null) return;

    final destAmount = _getDestAmount();
    if (destAmount <= BigInt.zero) return;

    setState(() {
      _isSwapping = true;
      _swapError = null;
    });

    try {
      // 1. Obtener wallets directamente (sin cambiar activeUnit)
      final destWallet = await walletProvider.getWallet(mintUrl, _destUnit);
      final srcWallet = await walletProvider.getWallet(mintUrl, _srcUnit);

      // 2. Crear mint quote en wallet destino → obtener invoice BOLT11
      String? invoice;
      final completer = Completer<String>();

      _mintSubscription?.cancel();
      _mintSubscription = destWallet.mint(
        amount: destAmount,
      ).listen(
        (quote) async {
          if (quote.state == MintQuoteState.unpaid && !completer.isCompleted) {
            completer.complete(quote.request);
          }
          if (quote.state == MintQuoteState.issued) {
            try {
              await walletProvider.saveSwapMintMetadata(
                destWallet, quote.request, destAmount,
              );
              if (mounted) _loadBalances();
            } catch (e) {
              debugPrint('Error saving swap mint metadata: $e');
            }
            _mintSubscription?.cancel();
            _mintSubscription = null;
          }
          if (quote.state == MintQuoteState.error && !completer.isCompleted) {
            completer.completeError(
              Exception(quote.error ?? 'Error creating mint quote'),
            );
          }
        },
        onError: (e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.completeError(Exception('Mint quote stream closed unexpectedly'));
          }
        },
      );

      invoice = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _mintSubscription?.cancel();
          throw Exception('Mint quote creation timed out');
        },
      );

      // 3. Obtener melt quote en wallet origen → fee
      final meltQuote = await srcWallet.meltQuote(request: invoice);

      if (!mounted) return;
      setState(() => _isSwapping = false);

      // 4. Mostrar confirmación con fee
      _showSwapConfirmation(
        meltQuote: meltQuote,
        srcWallet: srcWallet,
        destWallet: destWallet,
        destAmount: destAmount,
      );
    } catch (e) {
      _mintSubscription?.cancel();
      if (!mounted) return;
      final l10n = L10n.of(context)!;
      final errorStr = e.toString().toLowerCase();
      setState(() {
        _isSwapping = false;
        if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
          _swapError = l10n.swapErrorInsufficient;
        } else if (errorStr.contains('expired')) {
          _swapError = l10n.swapErrorExpired;
        } else {
          _swapError = l10n.swapErrorGeneric(e.toString());
        }
      });
    }
  }

  /// Muestra modal de confirmación con desglose de fee.
  void _showSwapConfirmation({
    required MeltQuote meltQuote,
    required Wallet srcWallet,
    required Wallet destWallet,
    required BigInt destAmount,
  }) {
    final l10n = L10n.of(context)!;
    final srcUnitLabel = UnitFormatter.getUnitLabel(_srcUnit);
    final destUnitLabel = UnitFormatter.getUnitLabel(_destUnit);
    final total = meltQuote.amount + meltQuote.feeReserve;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.deepVoidPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Icono swap
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.arrowLeftRight,
                color: AppColors.primaryAction,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Título
            Text(
              l10n.confirmPayment,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),

            // Destino: lo que recibes
            Text(
              '+ ${UnitFormatter.formatBalance(destAmount, _destUnit)} $destUnitLabel',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 4),

            // Origen: lo que pagas
            Text(
              '- ${UnitFormatter.formatBalance(meltQuote.amount, _srcUnit)} $srcUnitLabel',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            // Fee
            Text(
              '+ ~${UnitFormatter.formatBalance(meltQuote.feeReserve, _srcUnit)} $srcUnitLabel ${l10n.fee}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),

            // Total
            Text(
              '${l10n.total} ${UnitFormatter.formatBalance(total, _srcUnit)} $srcUnitLabel',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAction,
              ),
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Botones
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _mintSubscription?.cancel();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: PrimaryButton(
                    text: l10n.swapAction,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _executeSwap(
                        meltQuote: meltQuote,
                        srcWallet: srcWallet,
                        destWallet: destWallet,
                        destAmount: destAmount,
                      );
                    },
                    height: 52,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingSmall),
          ],
        ),
      ),
    );
  }

  /// Ejecuta el swap: melt en origen, guarda metadata de ambos lados.
  Future<void> _executeSwap({
    required MeltQuote meltQuote,
    required Wallet srcWallet,
    required Wallet destWallet,
    required BigInt destAmount,
  }) async {
    final l10n = L10n.of(context)!;
    final walletProvider = context.read<WalletProvider>();
    final invoice = meltQuote.request;

    setState(() {
      _isSwapping = true;
      _swapError = null;
    });

    try {
      // Ejecutar melt (paga el invoice Lightning)
      await srcWallet.melt(quote: meltQuote);

      // Guardar metadata del melt (lado enviado)
      await walletProvider.saveSwapMeltMetadata(
        srcWallet, invoice, meltQuote.amount,
      );

      // No cancelar _mintSubscription: el listener espera el estado
      // `issued` para guardar metadata del mint y recargar balances.

      if (!mounted) return;

      // Éxito: recargar balances, confetti, snackbar
      await _loadBalances();
      if (!mounted) return;

      walletProvider.confettiController.fire();

      // Limpiar campos
      _isUpdating = true;
      _fromController.clear();
      _toController.clear();
      _isUpdating = false;

      setState(() {
        _isSwapping = false;
        _swapError = null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.swapSuccess),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _mintSubscription?.cancel();
      _mintSubscription = null;
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      setState(() {
        _isSwapping = false;
        if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
          _swapError = l10n.swapErrorInsufficient;
        } else if (errorStr.contains('expired')) {
          _swapError = l10n.swapErrorExpired;
        } else {
          _swapError = l10n.swapErrorGeneric(e.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final priceProvider = context.watch<PriceProvider>();

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.swap,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                WalletProvider.cubaBitcoinMint.replaceFirst('https://', ''),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Precio + chart (arriba)
                _buildPriceChart(priceProvider),

                // Cards De/A centradas verticalmente
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFromCard(l10n),
                          _buildFlipButton(),
                          _buildToCard(l10n),
                        ],
                      ),
                    ),
                  ),
                ),

                // Validación + errores + botón fijo abajo
                Builder(builder: (_) {
                  final minError = _validateMinimums(l10n);
                  final errorMsg = _swapError ?? minError;
                  final canSwap = _fromController.text.isNotEmpty &&
                      _toController.text.isNotEmpty &&
                      minError == null &&
                      !_isSwapping;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (errorMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            errorMsg,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      PrimaryButton(
                        text: _isSwapping
                            ? l10n.swapProcessing
                            : l10n.swapAction,
                        isLoading: _isSwapping,
                        onPressed: canSwap ? _startSwap : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildPriceChart(PriceProvider priceProvider) {
    final btcPrice = priceProvider.btcPriceUsd;
    final priceStr = btcPrice != null
        ? '\$${NumberFormat('#,###').format(btcPrice.round())}'
        : '...';

    String rateStr = '...';
    if (btcPrice != null && btcPrice > 0) {
      final satsPerDollar = (100000000 / btcPrice).round();
      rateStr = '1 USD ≈ ${NumberFormat('#,###').format(satsPerDollar)} sats';
    }

    final isUpTrend =
        _chartData.length >= 2 && _chartData.last >= _chartData.first;
    final trendColor = isUpTrend ? AppColors.success : AppColors.error;

    return Column(
      children: [
        // Price
        Text(
          priceStr,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'USD',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),

        // Sparkline (sin contenedor, integrado)
        SizedBox(
          height: 40,
          width: double.infinity,
          child: _isLoadingChart
              ? Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                )
              : CustomPaint(
                  painter: _SparklinePainter(
                    data: _chartData,
                    lineColor: trendColor,
                    fillColor: trendColor.withValues(alpha: 0.08),
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Exchange rate
        Text(
          rateStr,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSwapCard({
    required L10n l10n,
    required String label,
    required String symbol,
    required String unitLabel,
    required String balance,
    required String unit,
    required TextEditingController controller,
    required bool isSats,
    bool showUseAll = false,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.balance}: $balance $unit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                  if (showUseAll) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _setMaxAmount,
                      child: Text(
                        l10n.swapUseAll,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$symbol $unitLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: !isSats,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  inputFormatters: [
                    if (isSats)
                      FilteringTextInputFormatter.digitsOnly
                    else
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlipButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: GestureDetector(
          onTap: _flipDirection,
          child: RotationTransition(
            turns: _flipAnimation,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.buttonGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAction.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.arrowUpDown,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFromCard(L10n l10n) {
    final fromSymbol = _isSatsToUsd ? '₿' : '\$';
    final fromLabel = _isSatsToUsd ? 'sats' : 'USD';
    final fromBalance = _isSatsToUsd
        ? UnitFormatter.formatBalance(_satsBalance, 'sat')
        : UnitFormatter.formatBalance(_usdBalance, 'usd');
    final fromUnit = _isSatsToUsd ? 'sat' : 'USD';

    return _buildSwapCard(
      l10n: l10n,
      label: l10n.swapFrom,
      symbol: fromSymbol,
      unitLabel: fromLabel,
      balance: fromBalance,
      unit: fromUnit,
      controller: _fromController,
      isSats: _isSatsToUsd,
      showUseAll: true,
    );
  }

  Widget _buildToCard(L10n l10n) {
    final toSymbol = _isSatsToUsd ? '\$' : '₿';
    final toLabel = _isSatsToUsd ? 'USD' : 'sats';
    final toBalance = _isSatsToUsd
        ? UnitFormatter.formatBalance(_usdBalance, 'usd')
        : UnitFormatter.formatBalance(_satsBalance, 'sat');
    final toUnit = _isSatsToUsd ? 'USD' : 'sat';

    return _buildSwapCard(
      l10n: l10n,
      label: l10n.swapTo,
      symbol: toSymbol,
      unitLabel: toLabel,
      balance: toBalance,
      unit: toUnit,
      controller: _toController,
      isSats: !_isSatsToUsd,
    );
  }

}

// --- Private widgets ---

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minVal = data.reduce(min);
    final maxVal = data.reduce(max);
    final range = maxVal - minVal;
    if (range == 0) return;

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height -
          ((data[i] - minVal) / range) * size.height * 0.85 -
          size.height * 0.075;
      points.add(Offset(x, y));
    }

    // Build smooth path using cubic bezier
    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
      fillPath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Fill gradient
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Smooth line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.lineColor != lineColor;
}


