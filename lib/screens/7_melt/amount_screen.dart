import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/lnurl_service.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/numpad_widget.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/price_provider.dart';

/// Pantalla para elegir monto en pagos LNURL/Lightning Address
class AmountScreen extends StatefulWidget {
  /// Destino (LNURL o Lightning Address)
  final String destination;

  /// Tipo de destino
  final LnInputType destinationType;

  /// Parámetros LNURL ya resueltos
  final LnurlPayParams params;

  const AmountScreen({
    super.key,
    required this.destination,
    required this.destinationType,
    required this.params,
  });

  @override
  State<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  String _amount = '';
  bool _isProcessing = false;
  String? _errorMessage;
  BigInt _availableBalance = BigInt.zero;
  late String _activeUnit;

  // Equivalente en la otra unidad (para mostrar)
  String? _equivalentDisplay;

  // Contador para evitar race conditions en _updateEquivalent
  int _equivalentGeneration = 0;

  @override
  void initState() {
    super.initState();
    _activeUnit = context.read<WalletProvider>().activeUnit;
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final walletProvider = context.read<WalletProvider>();
    final balance = await walletProvider.getBalance();
    if (mounted) {
      setState(() => _availableBalance = balance);
    }
  }

  /// Obtiene el monto ingresado en la unidad base (centavos para USD, sats para sat)
  BigInt get _amountInBaseUnit {
    return UnitFormatter.parseRawDigits(_amount, _activeUnit);
  }

  /// Verifica si la unidad activa es fiat (necesita conversión)
  bool get _isFiatUnit {
    return _activeUnit.toLowerCase() == 'usd' || _activeUnit.toLowerCase() == 'eur';
  }

  /// Convierte el monto a sats para LNURL
  Future<BigInt> _getAmountInSats() async {
    if (!_isFiatUnit) {
      // Ya está en sats
      return _amountInBaseUnit;
    }

    // Convertir fiat a sats usando PriceProvider
    final priceProvider = context.read<PriceProvider>();
    return await priceProvider.fiatCentsToSats(_amountInBaseUnit, _activeUnit);
  }

  /// Actualiza el equivalente mostrado
  Future<void> _updateEquivalent() async {
    final gen = ++_equivalentGeneration;

    if (_amount.isEmpty || _amountInBaseUnit == BigInt.zero) {
      setState(() => _equivalentDisplay = null);
      return;
    }

    try {
      final priceProvider = context.read<PriceProvider>();

      if (_isFiatUnit) {
        // Mostrar equivalente en sats
        final sats = await priceProvider.fiatCentsToSats(_amountInBaseUnit, _activeUnit);
        if (gen != _equivalentGeneration) return; // Descartar si hay llamada más reciente
        setState(() {
          _equivalentDisplay = '≈ ${UnitFormatter.formatBalance(sats, 'sat')} sat';
        });
      } else {
        // Mostrar equivalente en USD si hay precio
        if (priceProvider.hasPrice) {
          final usdCents = await priceProvider.satsToFiatCents(_amountInBaseUnit, 'usd');
          if (gen != _equivalentGeneration) return; // Descartar si hay llamada más reciente
          setState(() {
            _equivalentDisplay = '≈ ${UnitFormatter.formatBalance(usdCents, 'usd')} USD';
          });
        }
      }
    } catch (_) {
      if (gen != _equivalentGeneration) return;
      setState(() => _equivalentDisplay = null);
    }
  }

  bool get _isAmountValid => _amountInBaseUnit > BigInt.zero;

  bool get _canPay {
    return _isAmountValid && !_isProcessing && _amountInBaseUnit <= _availableBalance;
  }

  String get _destinationLabel {
    return widget.destinationType == LnInputType.lightningAddress
        ? 'Lightning Address'
        : 'LNURL';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

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
            l10n.send,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    children: [
                      // Destino
                      _buildDestinationCard(),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Display del monto
                      _buildAmountDisplay(),
                      const SizedBox(height: AppDimensions.paddingSmall),

                      // Rango permitido (siempre en sats porque es LNURL)
                      _buildRangeInfo(),
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Teclado numérico
                      _buildNumpad(),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: AppDimensions.paddingMedium),
                        _buildErrorMessage(),
                      ],
                    ],
                  ),
                ),
              ),

              // Balance y botón pagar
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    _buildBalanceInfo(),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    _buildPayButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAction.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.destinationType == LnInputType.lightningAddress
                  ? LucideIcons.atSign
                  : LucideIcons.link,
              color: AppColors.primaryAction,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _destinationLabel,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Payment to ${widget.destination}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    final displayAmount = UnitFormatter.formatRawDigitsForDisplay(_amount, _activeUnit);
    final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

    return Column(
      children: [
        Text(
          displayAmount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: _isAmountValid || _amount.isEmpty
                ? Colors.white
                : AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unitLabel,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
        // Mostrar equivalente en la otra unidad
        if (_equivalentDisplay != null) ...[
          const SizedBox(height: 4),
          Text(
            _equivalentDisplay!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRangeInfo() {
    // LNURL min/max siempre en sats
    final min = widget.params.minSats;
    final max = widget.params.maxSats;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Min: $min  •  Max: $max sat',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return NumpadWidget(
      value: _amount,
      onChanged: (newValue) {
        setState(() {
          _errorMessage = null;
          _amount = newValue;
        });
        // Actualizar equivalente de forma asíncrona
        _updateEquivalent();
      },
    );
  }

  Widget _buildBalanceInfo() {
    final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${L10n.of(context)!.available} ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${UnitFormatter.formatBalance(_availableBalance, _activeUnit)} $unitLabel',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryAction,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    final l10n = L10n.of(context)!;

    return PrimaryButton(
      text: _isProcessing ? l10n.paying : l10n.payInvoice,
      onPressed: _canPay ? _processPayment : null,
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_canPay) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // 1. Convertir monto a sats para LNURL
      final amountSats = await _getAmountInSats();

      // Validar contra límites LNURL
      if (!widget.params.isAmountValid(amountSats)) {
        setState(() {
          _isProcessing = false;
          _errorMessage = L10n.of(context)!.amountOutOfRange;
        });
        return;
      }

      // 2. Obtener invoice desde LNURL callback
      final invoiceResult = await LnurlService.fetchInvoice(
        widget.params.callback,
        amountSats,
      );

      if (!mounted) return;

      // 3. Obtener quote del mint (en la unidad del mint)
      final walletProvider = context.read<WalletProvider>();
      final quote = await walletProvider.getMeltQuote(invoiceResult.invoice);

      if (!mounted) return;

      final total = quote.amount + quote.feeReserve;

      // 4. Verificar balance suficiente
      if (total > _availableBalance) {
        setState(() {
          _isProcessing = false;
          _errorMessage = L10n.of(context)!.insufficientBalance;
        });
        return;
      }

      // 5. Mostrar confirmación (montos del mint, en activeUnit)
      final confirmed = await _showConfirmation(quote.amount, quote.feeReserve, total);

      if (!confirmed) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }
      if (!mounted) return;

      // 6. Ejecutar pago
      final totalPaid = await walletProvider.melt(quote);

      if (!mounted) return;

      // 7. Mostrar éxito y volver
      final l10n = L10n.of(context)!;
      final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sent('-${UnitFormatter.formatBalance(totalPaid, _activeUnit)}', unitLabel)),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );

      // Volver a home (pop dos veces: AmountScreen y MeltScreen)
      Navigator.pop(context);
      Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = _parseError(e.toString());
        });
      }
    }
  }

  String _parseError(String error) {
    final lower = error.toLowerCase();
    final l10n = L10n.of(context)!;

    if (lower.contains('insufficient') || lower.contains('not enough')) {
      return l10n.insufficientBalance;
    } else if (lower.contains('expired')) {
      return l10n.invoiceExpired;
    } else if (lower.contains('min') || lower.contains('max')) {
      return l10n.amountOutOfRange;
    } else if (lower.contains('precio') || lower.contains('price')) {
      return 'No se pudo obtener el precio de BTC';
    }

    return error.replaceFirst('Exception: ', '');
  }

  Future<bool> _showConfirmation(BigInt amount, BigInt fee, BigInt total) async {
    final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.deepVoidPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
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

            // Icono
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryAction.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.zap,
                color: AppColors.primaryAction,
                size: 32,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            // Título
            Text(
              L10n.of(context)!.confirmPayment,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),

            // Monto (en la unidad del mint)
            Text(
              '${UnitFormatter.formatBalance(amount, _activeUnit)} $unitLabel',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '+ ~${UnitFormatter.formatBalance(fee, _activeUnit)} $unitLabel fee',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              'Total: ${UnitFormatter.formatBalance(total, _activeUnit)} $unitLabel',
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
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          L10n.of(context)!.cancel,
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
                    text: L10n.of(context)!.pay,
                    onPressed: () => Navigator.pop(context, true),
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

    return result ?? false;
  }
}
