import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cdk_flutter/cdk_flutter.dart' hide WalletProvider;
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/wallet_provider.dart';

/// Pantalla para retirar sats a Lightning (Melt)
class MeltScreen extends StatefulWidget {
  const MeltScreen({super.key});

  @override
  State<MeltScreen> createState() => _MeltScreenState();
}

class _MeltScreenState extends State<MeltScreen> {
  final TextEditingController _invoiceController = TextEditingController();

  late String _activeUnit;

  bool _isValidInvoice = false;
  bool _isLoadingQuote = false;
  bool _isProcessing = false;
  MeltQuote? _quote;
  BigInt _invoiceAmount = BigInt.zero;
  BigInt _feeReserve = BigInt.zero;
  BigInt _total = BigInt.zero;
  BigInt _availableBalance = BigInt.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _activeUnit = context.read<WalletProvider>().activeUnit;
    _loadBalance();
  }

  /// Obtiene la etiqueta de la unidad para display
  String get _unitLabel => UnitFormatter.getUnitLabel(_activeUnit);

  Future<void> _loadBalance() async {
    final walletProvider = context.read<WalletProvider>();
    final balance = await walletProvider.getBalance();
    if (mounted) {
      setState(() {
        _availableBalance = balance;
      });
    }
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            'Retirar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instrucciones
                Text(
                  'Pega el invoice Lightning:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                // Campo de texto para el invoice
                _buildInvoiceInput(),

                const SizedBox(height: AppDimensions.paddingMedium),

                // Botón pegar del portapapeles
                _buildPasteButton(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Loading quote
                if (_isLoadingQuote) _buildLoadingQuote(),

                // Preview del invoice (si es válido)
                if (_isValidInvoice && _quote != null && !_isLoadingQuote)
                  _buildInvoicePreview(),

                // Mensaje de error (si hay)
                if (_errorMessage != null) _buildErrorMessage(),

                const Spacer(),

                // Balance disponible
                _buildBalanceInfo(),

                const SizedBox(height: AppDimensions.paddingMedium),

                // Botón pagar invoice
                _buildPayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceInput() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: TextField(
        controller: _invoiceController,
        maxLines: 3,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'lnbc1000n1pj...',
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingSmall),
        ),
        onChanged: _onInvoiceChanged,
      ),
    );
  }

  Widget _buildPasteButton() {
    return GestureDetector(
      onTap: _pasteFromClipboard,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall + 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.clipboard,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pegar del portapapeles',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingQuote() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryAction,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Obteniendo quote...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicePreview() {
    final hasEnoughBalance = _total <= _availableBalance;

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          // Estado válido
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  color: AppColors.success,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Invoice válido',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Monto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monto:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${UnitFormatter.formatBalance(_invoiceAmount, _activeUnit)} $_unitLabel',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Fee estimado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee reservado:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '~${UnitFormatter.formatBalance(_feeReserve, _activeUnit)} $_unitLabel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Separador
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${UnitFormatter.formatBalance(_total, _activeUnit)} $_unitLabel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: hasEnoughBalance
                      ? AppColors.primaryAction
                      : AppColors.error,
                ),
              ),
            ],
          ),

          if (!hasEnoughBalance) ...[
            const SizedBox(height: 8),
            Text(
              'Balance insuficiente',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
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
          width: 1,
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

  Widget _buildBalanceInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Disponible: ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${UnitFormatter.formatBalance(_availableBalance, _activeUnit)} $_unitLabel',
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
    final canPay = _isValidInvoice &&
        _quote != null &&
        !_isProcessing &&
        !_isLoadingQuote &&
        _total <= _availableBalance;

    return PrimaryButton(
      text: _isProcessing ? 'Pagando...' : 'Pagar invoice',
      onPressed: canPay ? _showConfirmation : null,
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _invoiceController.text = clipboardData!.text!.trim();
      _onInvoiceChanged(clipboardData.text!.trim());
    }
  }

  void _onInvoiceChanged(String value) {
    setState(() {
      _errorMessage = null;
      _quote = null;
      _isValidInvoice = false;

      if (value.isEmpty) {
        _invoiceAmount = BigInt.zero;
        _feeReserve = BigInt.zero;
        _total = BigInt.zero;
        return;
      }
    });

    // Verificar formato básico
    final trimmed = value.trim().toLowerCase();
    if (!trimmed.startsWith('lnbc') &&
        !trimmed.startsWith('lntb') &&
        !trimmed.startsWith('lnbcrt')) {
      setState(() {
        _errorMessage = 'Invoice inválido';
      });
      return;
    }

    // Obtener quote real
    _getQuote(value.trim());
  }

  Future<void> _getQuote(String invoice) async {
    setState(() {
      _isLoadingQuote = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      final quote = await walletProvider.getMeltQuote(invoice);

      if (mounted) {
        setState(() {
          _quote = quote;
          _invoiceAmount = quote.amount;
          _feeReserve = quote.feeReserve;
          _total = _invoiceAmount + _feeReserve;
          _isValidInvoice = true;
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingQuote = false;
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('expired')) {
            _errorMessage = 'Invoice expirado';
          } else if (errorStr.contains('invalid') || errorStr.contains('decode')) {
            _errorMessage = 'Invoice inválido o malformado';
          } else {
            _errorMessage = 'Error al obtener quote: $e';
          }
        });
      }
    }
  }

  void _showConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConfirmationModal(
        amount: _invoiceAmount,
        fee: _feeReserve,
        total: _total,
        unit: _activeUnit,
        onConfirm: () {
          Navigator.pop(context);
          _payInvoice();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _payInvoice() async {
    if (_quote == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      // Pagar invoice real
      final totalPaid = await walletProvider.melt(_quote!);

      if (mounted) {
        // Mostrar éxito y volver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('-${UnitFormatter.formatBalance(totalPaid, _activeUnit)} $_unitLabel enviados'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
          _errorMessage = 'Balance insuficiente';
        } else if (errorStr.contains('expired')) {
          _errorMessage = 'Invoice expirado';
        } else if (errorStr.contains('already paid')) {
          _errorMessage = 'Invoice ya fue pagado';
        } else {
          _errorMessage = 'Error al pagar: $e';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

/// Modal de confirmación
class _ConfirmationModal extends StatelessWidget {
  final BigInt amount;
  final BigInt fee;
  final BigInt total;
  final String unit;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmationModal({
    required this.amount,
    required this.fee,
    required this.total,
    required this.unit,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Confirmar pago',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Detalles
          Text(
            '${UnitFormatter.formatBalance(amount, unit)} ${UnitFormatter.getUnitLabel(unit)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '+ ~${UnitFormatter.formatBalance(fee, unit)} ${UnitFormatter.getUnitLabel(unit)} fee',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Total: ${UnitFormatter.formatBalance(total, unit)} ${UnitFormatter.getUnitLabel(unit)}',
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
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
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
                  text: 'Pagar',
                  onPressed: onConfirm,
                  height: 52,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingSmall),
        ],
      ),
    );
  }
}
