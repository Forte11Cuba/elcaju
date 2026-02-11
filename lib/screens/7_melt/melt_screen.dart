import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cdk_flutter/cdk_flutter.dart' hide WalletProvider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/incoming_data_parser.dart';
import '../../core/services/lnurl_service.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/wallet_provider.dart';
import '../10_scanner/scan_screen.dart';
import 'amount_screen.dart';

/// Pantalla para retirar sats a Lightning (Melt)
class MeltScreen extends StatefulWidget {
  /// Invoice inicial (pre-cargado desde QR scanner o deep link)
  final String? initialInvoice;

  const MeltScreen({super.key, this.initialInvoice});

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

  // Estado para LNURL/Lightning Address (solo para mostrar loading)
  LnInputType _inputType = LnInputType.unknown;
  bool _isResolvingLnurl = false;

  @override
  void initState() {
    super.initState();
    _activeUnit = context.read<WalletProvider>().activeUnit;
    _loadBalance();
    // Pre-cargar invoice inicial si existe
    if (widget.initialInvoice != null && widget.initialInvoice!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _invoiceController.text = widget.initialInvoice!;
        _onInvoiceChanged(widget.initialInvoice!);
      });
    }
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
          title: Text(
            L10n.of(context)!.withdraw,
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
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instrucciones
                      Text(
                        L10n.of(context)!.pasteLightningInvoice,
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

                      // Botones pegar y escanear
                      _buildActionButtons(),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Loading LNURL resolve
                      if (_isResolvingLnurl) _buildResolvingLnurl(),

                      // Loading quote
                      if (_isLoadingQuote) _buildLoadingQuote(),

                      // Preview del invoice (si es válido)
                      if (_isValidInvoice && _quote != null && !_isLoadingQuote)
                        _buildInvoicePreview(),

                      // Mensaje de error (si hay)
                      if (_errorMessage != null) _buildErrorMessage(),
                    ],
                  ),
                ),
              ),

              // Balance y botón (fijos abajo)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    // Balance disponible
                    _buildBalanceInfo(),

                    const SizedBox(height: AppDimensions.paddingMedium),

                    // Botón pagar invoice
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
          hintText: 'lnbc..., lnurl1..., user@domain.com',
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Botón pegar (expandido)
        Expanded(child: _buildPasteButton()),
        const SizedBox(width: 12),
        // Botón escanear QR
        _buildScanButton(),
      ],
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
              L10n.of(context)!.pasteFromClipboard,
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

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall + 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.buttonGradient,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.scan,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(mode: ScanMode.invoiceOnly),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      _invoiceController.text = result;
      _onInvoiceChanged(result);
    }
  }

  Widget _buildResolvingLnurl() {
    final typeLabel = _inputType == LnInputType.lightningAddress
        ? 'Lightning Address'
        : 'LNURL';

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
            L10n.of(context)!.resolvingType(typeLabel),
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
            L10n.of(context)!.gettingQuote,
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
                L10n.of(context)!.validInvoice,
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
                L10n.of(context)!.amount,
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
                L10n.of(context)!.feeReserved,
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
              Text(
                L10n.of(context)!.total,
                style: const TextStyle(
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
              L10n.of(context)!.insufficientBalance,
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
          '${L10n.of(context)!.available} ',
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
    final l10n = L10n.of(context)!;
    final hasInput = _invoiceController.text.trim().isNotEmpty;

    // Para BOLT11 con quote válido: botón Pagar
    final hasValidQuote = _isValidInvoice && _quote != null && _total <= _availableBalance;

    // Para LNURL/Address, unknown, o BOLT11 sin quote válido: botón Continuar
    final needsProcessing = _inputType == LnInputType.lnurl ||
        _inputType == LnInputType.lightningAddress ||
        _inputType == LnInputType.unknown ||
        (_inputType == LnInputType.bolt11Invoice && !hasValidQuote);

    // Determinar estado del botón
    final canPay = !_isProcessing && !_isLoadingQuote && !_isResolvingLnurl && hasValidQuote;
    final canContinue = !_isProcessing && !_isLoadingQuote && !_isResolvingLnurl &&
        hasInput && needsProcessing;

    // Texto del botón
    String buttonText;
    if (_isProcessing) {
      buttonText = l10n.paying;
    } else if (needsProcessing && !hasValidQuote) {
      buttonText = l10n.continue_;
    } else {
      buttonText = l10n.payInvoice;
    }

    return PrimaryButton(
      text: buttonText,
      onPressed: canPay ? _handlePay : (canContinue ? _processInput : null),
    );
  }

  Future<void> _handlePay() async {
    // Cerrar teclado
    FocusScope.of(context).unfocus();
    // Flujo normal con invoice directo
    _showConfirmation();
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
        _inputType = LnInputType.unknown;
        _invoiceAmount = BigInt.zero;
        _feeReserve = BigInt.zero;
        _total = BigInt.zero;
        return;
      }
    });

    // Detectar tipo de input (sin mostrar error, solo detectar)
    final inputType = LnurlService.detectType(value);
    setState(() => _inputType = inputType);

    // Solo procesar automáticamente invoices BOLT11
    // LNURL y Lightning Address requieren botón explícito
    if (inputType == LnInputType.bolt11Invoice) {
      // BOLT11 invoices son 200+ chars; evitar llamar API con input parcial
      final cleaned = LnurlService.cleanInput(value);
      if (cleaned.length > 50) {
        _getQuote(cleaned);
      }
    }
    // No mostrar error para unknown - el usuario puede estar escribiendo
  }

  /// Procesa el input actual (llamado por botón Continuar)
  void _processInput() {
    final value = _invoiceController.text.trim();
    if (value.isEmpty) return;

    // Cerrar teclado
    FocusScope.of(context).unfocus();

    switch (_inputType) {
      case LnInputType.bolt11Invoice:
        if (_quote != null) {
          // Quote válido, mostrar confirmación
          _showConfirmation();
        } else {
          // Sin quote, intentar obtenerlo o mostrar error
          final cleaned = LnurlService.cleanInput(value);
          if (cleaned.length > 50) {
            _getQuote(cleaned);
          } else {
            setState(() {
              _errorMessage = L10n.of(context)!.invalidInvoiceMalformed;
            });
          }
        }
        break;

      case LnInputType.lnurl:
        _resolveLnurl(value);
        break;

      case LnInputType.lightningAddress:
        _resolveLightningAddress(value);
        break;

      case LnInputType.unknown:
        setState(() {
          _errorMessage = L10n.of(context)!.invalidInvoice;
        });
        break;
    }
  }

  Future<void> _resolveLnurl(String lnurl) async {
    setState(() {
      _isResolvingLnurl = true;
      _errorMessage = null;
    });

    try {
      final params = await LnurlService.resolveLnurl(lnurl);
      if (mounted) {
        setState(() => _isResolvingLnurl = false);
        // Navegar a AmountScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountScreen(
              destination: lnurl,
              destinationType: LnInputType.lnurl,
              params: params,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolvingLnurl = false;
          _errorMessage = L10n.of(context)!.paymentError(e.toString().replaceFirst('Exception: ', ''));
        });
      }
    }
  }

  Future<void> _resolveLightningAddress(String address) async {
    setState(() {
      _isResolvingLnurl = true;
      _errorMessage = null;
    });

    try {
      final params = await LnurlService.resolveLightningAddress(address);
      if (mounted) {
        setState(() => _isResolvingLnurl = false);
        // Navegar a AmountScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountScreen(
              destination: address,
              destinationType: LnInputType.lightningAddress,
              params: params,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResolvingLnurl = false;
          _errorMessage = L10n.of(context)!.paymentError(e.toString().replaceFirst('Exception: ', ''));
        });
      }
    }
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
        final l10n = L10n.of(context)!;
        setState(() {
          _isLoadingQuote = false;
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('expired')) {
            _errorMessage = l10n.invoiceExpired;
          } else if (errorStr.contains('invalid') || errorStr.contains('decode')) {
            _errorMessage = l10n.invalidInvoiceMalformed;
          } else {
            _errorMessage = l10n.paymentError(e.toString());
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
        final l10n = L10n.of(context)!;
        // Mostrar éxito y volver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.sent('-${UnitFormatter.formatBalance(totalPaid, _activeUnit)}', _unitLabel)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = L10n.of(context)!;
      final errorStr = e.toString().toLowerCase();
      String errorMessage;
      if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
        errorMessage = l10n.insufficientBalance;
      } else if (errorStr.contains('expired')) {
        errorMessage = l10n.invoiceExpired;
      } else if (errorStr.contains('already paid')) {
        errorMessage = l10n.invoiceAlreadyPaid;
      } else {
        errorMessage = l10n.paymentError(e.toString());
      }
      setState(() {
        _errorMessage = errorMessage;
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
