import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cdk_flutter/cdk_flutter.dart' hide WalletProvider;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/effects/cashu_confetti.dart';
import '../../providers/wallet_provider.dart';

/// Estados del proceso de mint
enum MintStatus { loading, unpaid, paid, issued, error }

/// Pantalla para mostrar el invoice generado y esperar el pago
class InvoiceScreen extends StatefulWidget {
  final BigInt amount;
  final String unit;
  final String? description;

  const InvoiceScreen({
    super.key,
    required this.amount,
    required this.unit,
    this.description,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  MintStatus _status = MintStatus.loading;
  String? _invoice;
  String? _errorMessage;
  StreamSubscription<MintQuote>? _mintSubscription;
  final CashuConfettiController _confettiController = CashuConfettiController();

  @override
  void initState() {
    super.initState();
    _startMintProcess();
  }

  @override
  void dispose() {
    _mintSubscription?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startMintProcess() {
    final walletProvider = context.read<WalletProvider>();

    try {
      final mintStream = walletProvider.mintTokens(
        widget.amount,
        widget.description,
      );

      _mintSubscription = mintStream.listen(
        (quote) {
          if (!mounted) return;

          setState(() {
            switch (quote.state) {
              case MintQuoteState.unpaid:
                _status = MintStatus.unpaid;
                _invoice = quote.request;
                break;

              case MintQuoteState.paid:
                _status = MintStatus.paid;
                break;

              case MintQuoteState.issued:
                _status = MintStatus.issued;
                _onMintCompleted();
                break;

              default:
                // Cualquier otro estado se trata como error
                _status = MintStatus.error;
                _errorMessage = L10n.of(context)!.unknownState;
            }
          });
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _status = MintStatus.error;
            _errorMessage = error.toString();
          });
        },
      );
    } catch (e) {
      setState(() {
        _status = MintStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _onMintCompleted() {
    // Disparar confetti inmediatamente
    _confettiController.fire();

    // Esperar a que termine el confetti antes de navegar
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final l10n = L10n.of(context)!;
        final formattedAmount = '+${UnitFormatter.formatBalance(widget.amount, widget.unit)}';
        final unitLabel = UnitFormatter.getUnitLabel(widget.unit);
        // Volver al home con mensaje de éxito
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.deposited(formattedAmount, unitLabel),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CashuConfetti(
      controller: _confettiController,
      child: GradientBackground(
        child: PopScope(
          canPop: _status == MintStatus.issued || _status == MintStatus.error,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: (_status == MintStatus.issued || _status == MintStatus.error)
                  ? IconButton(
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Text(
                L10n.of(context)!.payInvoiceTitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              actions: [
                if (_status == MintStatus.unpaid)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      L10n.of(context)!.cancel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case MintStatus.loading:
        return _buildLoading();
      case MintStatus.unpaid:
      case MintStatus.paid:
      case MintStatus.issued:
        return _buildInvoiceView();
      case MintStatus.error:
        return _buildError();
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryAction,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            L10n.of(context)!.generatingInvoice,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceView() {
    return Column(
      children: [
        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título con monto
                _buildHeader(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // QR del invoice
                if (_invoice != null) _buildQRSection(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Invoice truncado
                if (_invoice != null) _buildInvoiceText(),

                const SizedBox(height: AppDimensions.paddingMedium),

                // Botón copiar
                if (_invoice != null && _status == MintStatus.unpaid) _buildCopyButton(),
              ],
            ),
          ),
        ),

        // Estado y descripción (fijos abajo)
        Column(
          children: [
            // Estado del invoice
            _buildStatus(),

            const SizedBox(height: AppDimensions.paddingMedium),

            // Descripción (si existe)
            if (widget.description != null && widget.description!.isNotEmpty)
              _buildDescription(),
          ],
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            L10n.of(context)!.error,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? L10n.of(context)!.unknownError,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                L10n.of(context)!.back,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = L10n.of(context)!;
    final formattedAmount = UnitFormatter.formatBalance(widget.amount, widget.unit);
    final unitLabel = UnitFormatter.getUnitLabel(widget.unit);

    return Column(
      children: [
        Text(
          l10n.depositAmountTitle(formattedAmount, unitLabel),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQRSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Center(
        child: QrImageView(
          data: _invoice!,
          version: QrVersions.auto,
          size: 200,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        ),
      ),
    );
  }

  Widget _buildInvoiceText() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: SelectableText(
        _invoice!,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );
  }

  Widget _buildCopyButton() {
    return GestureDetector(
      onTap: _copyInvoice,
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
            Icon(LucideIcons.copy, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              L10n.of(context)!.copyInvoice,
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

  Widget _buildStatus() {
    final l10n = L10n.of(context)!;
    IconData icon;
    String text;
    Color color;

    switch (_status) {
      case MintStatus.loading:
        icon = LucideIcons.clock;
        text = l10n.generating;
        color = AppColors.textSecondary;
        break;
      case MintStatus.unpaid:
        icon = LucideIcons.clock;
        text = l10n.waitingForPayment;
        color = AppColors.textSecondary;
        break;
      case MintStatus.paid:
        icon = LucideIcons.checkCircle;
        text = l10n.paymentReceived;
        color = AppColors.success;
        break;
      case MintStatus.issued:
        icon = LucideIcons.checkCircle2;
        text = l10n.tokensIssued;
        color = AppColors.success;
        break;
      case MintStatus.error:
        icon = LucideIcons.xCircle;
        text = l10n.error;
        color = AppColors.error;
        break;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_status == MintStatus.unpaid || _status == MintStatus.loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.of(context)!.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.description!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyInvoice() async {
    if (_invoice == null) return;
    await Clipboard.setData(ClipboardData(text: _invoice!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.invoiceCopiedToClipboard),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
