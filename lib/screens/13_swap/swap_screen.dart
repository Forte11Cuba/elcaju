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
  final _amountController = TextEditingController();
  String _convertedAmount = '';

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  BigInt _satsBalance = BigInt.zero;
  BigInt _usdBalance = BigInt.zero;

  List<double> _chartData = [];
  bool _isLoadingChart = true;

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
    _amountController.addListener(_calculateConversion);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBalances();
      _loadChartData();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = walletProvider.activeMintUrl;
    if (mintUrl == null) return;

    final balances = await walletProvider.getBalancesForMint(mintUrl);
    if (mounted) {
      setState(() {
        _satsBalance = balances['sat'] ?? BigInt.zero;
        _usdBalance = balances['usd'] ?? BigInt.zero;
      });
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

  void _calculateConversion() {
    final text = _amountController.text;
    if (text.isEmpty) {
      setState(() => _convertedAmount = '');
      return;
    }

    final priceProvider = context.read<PriceProvider>();
    final btcPrice = priceProvider.btcPriceUsd;
    if (btcPrice == null || btcPrice == 0) {
      setState(() => _convertedAmount = '...');
      return;
    }

    try {
      if (_isSatsToUsd) {
        final sats = int.tryParse(text) ?? 0;
        final usdAmount = sats / 100000000 * btcPrice;
        setState(() {
          _convertedAmount = usdAmount < 0.01 && usdAmount > 0
              ? '< \$0.01'
              : '\$${usdAmount.toStringAsFixed(2)}';
        });
      } else {
        final usd = double.tryParse(text) ?? 0;
        final sats = (usd / btcPrice * 100000000).round();
        setState(() {
          _convertedAmount = '${NumberFormat('#,###').format(sats)} sat';
        });
      }
    } catch (_) {
      setState(() => _convertedAmount = '...');
    }
  }

  void _flipDirection() {
    HapticFeedback.mediumImpact();
    if (_isSatsToUsd) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isSatsToUsd = !_isSatsToUsd;
      _amountController.clear();
      _convertedAmount = '';
    });
  }

  void _setQuickAmount(String amount) {
    _amountController.text = amount;
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amount.length),
    );
  }

  void _setMaxAmount() {
    if (_isSatsToUsd) {
      _setQuickAmount(_satsBalance.toString());
    } else {
      final usd = _usdBalance.toDouble() / 100;
      _setQuickAmount(usd.toStringAsFixed(2));
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
          title: Text(
            l10n.swap,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                _buildPriceChart(priceProvider),
                const SizedBox(height: AppDimensions.paddingMedium),
                const SizedBox(height: AppDimensions.paddingLarge),
                _buildFromCard(l10n),
                _buildFlipButton(),
                _buildToCard(l10n),
                const SizedBox(height: AppDimensions.paddingMedium),
                const SizedBox(height: AppDimensions.paddingLarge),
                PrimaryButton(
                  text: l10n.swapAction,
                  onPressed: _amountController.text.isNotEmpty
                      ? () {
                          // TODO: implement swap logic
                          HapticFeedback.heavyImpact();
                        }
                      : null,
                ),
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

  Widget _buildFromCard(L10n l10n) {
    final fromSymbol = _isSatsToUsd ? '₿' : '\$';
    final fromLabel = _isSatsToUsd ? 'sats' : 'USD';
    final fromBalance = _isSatsToUsd
        ? UnitFormatter.formatBalance(_satsBalance, 'sat')
        : UnitFormatter.formatBalance(_usdBalance, 'usd');
    final fromUnit = _isSatsToUsd ? 'sat' : 'USD';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Balance en la misma línea
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.swapFrom,
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
                    '${l10n.balance}: $fromBalance $fromUnit',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
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
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Unit pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$fromSymbol $fromLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Amount input
              Expanded(
                child: TextField(
                  key: ValueKey('from_$_isSatsToUsd'),
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: !_isSatsToUsd,
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
                    if (_isSatsToUsd)
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

  Widget _buildToCard(L10n l10n) {
    final toSymbol = _isSatsToUsd ? '\$' : '₿';
    final toLabel = _isSatsToUsd ? 'USD' : 'sats';
    final toBalance = _isSatsToUsd
        ? UnitFormatter.formatBalance(_usdBalance, 'usd')
        : UnitFormatter.formatBalance(_satsBalance, 'sat');
    final toUnit = _isSatsToUsd ? 'USD' : 'sat';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Balance en la misma línea
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.swapTo,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '${l10n.balance}: $toBalance $toUnit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
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
                  '$toSymbol $toLabel',
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
                child: Text(
                  _convertedAmount.isEmpty ? '≈ 0' : '≈ $_convertedAmount',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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


