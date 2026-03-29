import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../src/rust/api/payment_request.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/wallet_provider.dart';

/// Pantalla de confirmación para pagar un Payment Request (NUT-18/26)
class PaymentRequestScreen extends StatefulWidget {
  /// Raw encoded payment request (creqA, CREQB1, or bitcoin:?creq=)
  final String encodedRequest;

  const PaymentRequestScreen({super.key, required this.encodedRequest});

  @override
  State<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends State<PaymentRequestScreen> {
  PaymentRequestInfo? _info;
  String? _parseError;
  bool _isPaying = false;
  String? _payError;

  @override
  void initState() {
    super.initState();
    _parseRequest();
  }

  void _parseRequest() {
    try {
      final info = PaymentRequestInfo.parse(encoded: widget.encodedRequest);
      setState(() => _info = info);
    } catch (e) {
      setState(() => _parseError = e.toString());
    }
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
          title: Text(
            l10n.paymentRequestTitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _parseError != null
            ? _buildError(l10n)
            : _info == null
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(l10n),
      ),
    );
  }

  Widget _buildError(L10n l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.paymentRequestErrorParsing,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _parseError!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(L10n l10n) {
    final info = _info!;
    final walletProvider = context.watch<WalletProvider>();
    final activeUnit = walletProvider.activeUnit;
    final requestUnit = info.unit ?? 'sat';

    // Validaciones
    final unitMismatch = info.unit != null && info.unit != activeUnit;
    String stripSlash(String url) =>
        url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final normalizedMints = info.mints.map(stripSlash).toSet();
    final activeMint = walletProvider.activeMintUrl;
    final mintNotAccepted = normalizedMints.isNotEmpty &&
        (activeMint == null || !normalizedMints.contains(stripSlash(activeMint)));
    final hasTransport = info.transports.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Monto
          if (info.amount != null)
            _buildAmountCard(info.amount!, requestUnit, l10n),

          const SizedBox(height: 16),

          // Detalles
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción
                if (info.description != null && info.description!.isNotEmpty) ...[
                  _buildDetailRow(
                    LucideIcons.fileText,
                    l10n.paymentRequestDescription,
                    info.description!,
                  ),
                  const SizedBox(height: 12),
                ],

                // Mints aceptados
                _buildDetailRow(
                  LucideIcons.server,
                  l10n.paymentRequestMints,
                  info.mints.isEmpty
                      ? l10n.paymentRequestAnyMint
                      : info.mints.map((m) => Uri.parse(m).host).join(', '),
                ),

                // Transporte (solo mostrar si hay transporte configurado)
                if (info.transports.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    LucideIcons.send,
                    l10n.paymentRequestTransport,
                    info.transports
                        .map((t) => t.transportType == 'nostr' ? 'Nostr (NIP-17)' : 'HTTP POST')
                        .join(', '),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Warnings
          if (unitMismatch)
            _buildWarning(
              LucideIcons.alertTriangle,
              l10n.paymentRequestUnitMismatch(requestUnit),
            ),
          if (mintNotAccepted)
            _buildWarning(
              LucideIcons.alertTriangle,
              l10n.paymentRequestMintNotAccepted,
            ),
          if (!hasTransport)
            _buildWarning(
              LucideIcons.info,
              l10n.paymentRequestNoTransport,
            ),

          if (_payError != null) ...[
            const SizedBox(height: 12),
            _buildWarning(LucideIcons.alertCircle, _payError!),
          ],

          const SizedBox(height: 32),

          // Botón pagar
          PrimaryButton(
            text: _isPaying ? l10n.paymentRequestPaying : l10n.paymentRequestPay,
            icon: LucideIcons.zap,
            isLoading: _isPaying,
            onPressed: (!hasTransport || _isPaying)
                ? null
                : _pay,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BigInt amount, String unit, L10n l10n) {
    return GlassCard(
      child: Column(
        children: [
          Text(
            l10n.paymentRequestAmount,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            UnitFormatter.formatBalanceWithUnit(amount, unit),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryAction),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarning(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() {
      _isPaying = true;
      _payError = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      await walletProvider.payPaymentRequest(
        widget.encodedRequest,
        customAmount: _info!.amount,
      );

      if (!mounted) return;

      // Éxito — mostrar snackbar y volver
      final l10n = L10n.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.paymentRequestSuccess),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _payError = e.toString();
      });
    }
  }
}
