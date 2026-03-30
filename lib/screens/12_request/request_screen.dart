import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../src/rust/api/wallet.dart';
import '../../src/rust/api/payment_request.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/bip321_builder.dart';
import '../../core/services/nfc_service.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/numpad_widget.dart';
import '../../providers/wallet_provider.dart';

enum RequestStatus { input, generating, waiting, received, error }
enum QrMode { universal, cashu, lightning }

/// Pantalla para solicitar pagos via Payment Request unificado.
/// Genera creqB (Cashu/Nostr) + Lightning invoice en paralelo.
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  // Input state
  String _amountValue = '';
  late String _activeUnit;

  // Request state
  RequestStatus _status = RequestStatus.input;
  String? _errorMessage;

  // Payment data
  String? _creqB;
  String? _bolt11;
  QrMode _activeMode = QrMode.cashu;
  bool _paymentHandled = false;

  // Listeners
  StreamSubscription<NostrPaymentEvent>? _nostrSubscription;
  StreamSubscription<MintQuote>? _mintSubscription;

  // NFC
  NfcState _nfcState = NfcState.unsupported;
  bool _nfcEmulating = false;

  // Success
  BigInt _receivedAmount = BigInt.zero;

  late final WalletProvider _walletProvider;

  @override
  void initState() {
    super.initState();
    _walletProvider = context.read<WalletProvider>();
    _activeUnit = _walletProvider.activeUnit;
    _checkNfc();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nostrSubscription?.cancel();
    _mintSubscription?.cancel();
    if (_nfcEmulating) NfcService.stopEmulating();
    // Clear persisted request if user abandoned without receiving payment
    if (!_paymentHandled && _creqB != null) {
      _walletProvider.removePendingNostrRequest();
    }
    super.dispose();
  }

  Future<void> _checkNfc() async {
    final state = await NfcService.checkState();
    if (mounted) setState(() => _nfcState = state);
  }

  String get _unitLabel => UnitFormatter.getUnitLabel(_activeUnit);
  BigInt get _amount => UnitFormatter.parseRawDigits(_amountValue, _activeUnit);
  bool get _isValidAmount => _amount > BigInt.zero;

  // ─── Build ───

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
            L10n.of(context)!.requestPayment,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            if (_status == RequestStatus.waiting)
              IconButton(
                icon: const Icon(LucideIcons.share2, color: Colors.white),
                onPressed: _shareRequest,
              ),
          ],
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case RequestStatus.input:
        return _buildInputView();
      case RequestStatus.generating:
        return _buildGeneratingView();
      case RequestStatus.waiting:
        return _buildWaitingView();
      case RequestStatus.received:
        return _buildSuccessView();
      case RequestStatus.error:
        return _buildErrorView();
    }
  }

  // ─── Input View ───

  Widget _buildInputView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAmountSection(),
                const SizedBox(height: AppDimensions.paddingLarge),
                _buildDescriptionSection(),
                const SizedBox(height: AppDimensions.paddingMedium),
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: PrimaryButton(
            text: L10n.of(context)!.generateRequest,
            onPressed: _isValidAmount ? _generateRequest : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    final displayAmount =
        UnitFormatter.formatRawDigitsForDisplay(_amountValue, _activeUnit);
    return Column(
      children: [
        Text(
          displayAmount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _isValidAmount || _amountValue.isEmpty
                ? Colors.white
                : AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _unitLabel,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        NumpadWidget(
          value: _amountValue,
          onChanged: (v) => setState(() {
            _errorMessage = null;
            _amountValue = v;
          }),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    final l10n = L10n.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.descriptionOptional,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        GlassCard(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: TextField(
            controller: _descriptionController,
            maxLines: 2,
            maxLength: 100,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: l10n.requestDescriptionHint,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              counterStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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

  // ─── Generating View ───

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryAction),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            L10n.of(context)!.generatingRequest,
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

  // ─── Waiting View (QR + sub-toggle + actions) ───

  Widget _buildWaitingView() {
    final l10n = L10n.of(context)!;
    final formattedAmount = UnitFormatter.formatBalance(_amount, _activeUnit);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Amount header
                Text(
                  '$formattedAmount $_unitLabel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                // QR Code with logo overlay
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        QrImageView(
                          data: _getActiveQrContent(),
                          version: QrVersions.auto,
                          size: 260,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: _activeMode == QrMode.universal
                              ? QrErrorCorrectLevel.M
                              : QrErrorCorrectLevel.H,
                        ),
                        if (_activeMode == QrMode.cashu)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/img/cashu.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        if (_activeMode == QrMode.lightning)
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.bitcoinOrange,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Icon(
                              LucideIcons.zap,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Sub-toggle: Universal / Cashu / Lightning
                _buildModeToggle(),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Action buttons: Copy, NFC, Share
                _buildActionButtons(),
                const SizedBox(height: AppDimensions.paddingMedium),

                // Status indicator
                _buildStatusIndicator(),
              ],
            ),
          ),
        ),

        // Cancel button
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
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
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            label: L10n.of(context)!.universal,
            mode: QrMode.universal,
            enabled: _bolt11 != null,
          ),
          _buildToggleButton(
            label: 'Cashu',
            mode: QrMode.cashu,
            enabled: true,
          ),
          _buildToggleButton(
            label: 'Lightning',
            mode: QrMode.lightning,
            enabled: _bolt11 != null,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required QrMode mode,
    required bool enabled,
  }) {
    final isActive = _activeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: enabled
            ? () {
                setState(() => _activeMode = mode);
                _updateNfcPayload();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: AppColors.buttonGradient)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: enabled
                    ? (isActive ? Colors.white : AppColors.textSecondary)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: LucideIcons.copy,
          label: L10n.of(context)!.copy,
          onTap: _copyRequest,
        ),
        if (_nfcState == NfcState.enabled) ...[
          const SizedBox(width: 16),
          _buildActionButton(
            icon: _nfcEmulating ? LucideIcons.wifiOff : LucideIcons.wifi,
            label: 'NFC',
            onTap: _toggleNfc,
            active: _nfcEmulating,
          ),
        ],
        const SizedBox(width: 16),
        _buildActionButton(
          icon: LucideIcons.share2,
          label: L10n.of(context)!.share,
          onTap: _shareRequest,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryAction.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(color: AppColors.primaryAction.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? AppColors.primaryAction : AppColors.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: active ? AppColors.primaryAction : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            L10n.of(context)!.waitingForPayment,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Success View ───

  Widget _buildSuccessView() {
    final l10n = L10n.of(context)!;
    final formattedAmount =
        '+${UnitFormatter.formatBalance(_receivedAmount, _activeUnit)}';
    final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            '$formattedAmount $unitLabel',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            l10n.requestPaymentReceived,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge * 2),
          PrimaryButton(
            text: l10n.backToHome,
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  // ─── Error View ───

  Widget _buildErrorView() {
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
          PrimaryButton(
            text: L10n.of(context)!.back,
            onPressed: () => setState(() {
              _status = RequestStatus.input;
              _errorMessage = null;
            }),
          ),
        ],
      ),
    );
  }

  // ─── Logic ───

  static const List<String> _defaultNostrRelays = [
    'wss://relay.damus.io',
    'wss://relay.primal.net',
    'wss://nos.lol',
  ];

  Future<void> _generateRequest() async {
    final walletProvider = context.read<WalletProvider>();
    final wallet = walletProvider.activeWallet;

    // Clean up previous request state — await to ensure Rust locks are released
    await _nostrSubscription?.cancel();
    _nostrSubscription = null;
    await _mintSubscription?.cancel();
    _mintSubscription = null;
    if (_nfcEmulating) {
      NfcService.stopEmulating();
      _nfcEmulating = false;
    }
    _paymentHandled = false;
    _creqB = null;
    _bolt11 = null;
    _activeMode = QrMode.cashu;

    setState(() => _status = RequestStatus.generating);

    if (wallet == null) {
      setState(() {
        _status = RequestStatus.error;
        _errorMessage = 'No active wallet';
      });
      return;
    }

    try {
      final description = _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null;

      // 1. Create payment request (creqB + Nostr keys)
      final request = await wallet.createPaymentRequest(
        params: CreateRequestParams(
          amount: _amount,
          unit: _activeUnit,
          description: description,
          nostrRelays: _defaultNostrRelays,
        ),
      );

      _creqB = request.creqB;

      // Persist handle for recovery if app is killed
      await walletProvider.savePendingNostrRequest(
        request.listenerHandle.toPersisted(),
      );

      // 2. Start Nostr listener
      _nostrSubscription = wallet
          .waitForNostrPayment(handle: request.listenerHandle)
          .listen(_onNostrEvent);

      // 3. Start Lightning invoice generation directly via CDK
      _mintSubscription = wallet
          .mint(amount: _amount, description: description)
          .listen(_onMintEvent);

      setState(() => _status = RequestStatus.waiting);
    } catch (e) {
      setState(() {
        _status = RequestStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _onNostrEvent(NostrPaymentEvent event) {
    if (!mounted || _paymentHandled) return;
    if (event.state == NostrPaymentState.received) {
      _paymentHandled = true;
      _mintSubscription?.cancel();
      _onPaymentSuccess(event.amount ?? _amount);
    }
  }

  void _onMintEvent(MintQuote quote) {
    if (!mounted) return;
    switch (quote.state) {
      case MintQuoteState.unpaid:
        if (_bolt11 == null) {
          setState(() {
            _bolt11 = quote.request;
            _activeMode = QrMode.universal;
          });
          _updateNfcPayload();
        }
        break;
      case MintQuoteState.issued:
        if (!_paymentHandled) {
          _paymentHandled = true;
          _nostrSubscription?.cancel();
          _onPaymentSuccess(quote.amount ?? _amount);
        }
        break;
      case MintQuoteState.error:
        // Lightning failed, but Nostr listener continues
        break;
      default:
        break;
    }
  }

  Future<void> _onPaymentSuccess(BigInt amount) async {
    if (_nfcEmulating) NfcService.stopEmulating();
    setState(() {
      _status = RequestStatus.received;
      _receivedAmount = amount;
    });
    final walletProvider = context.read<WalletProvider>();
    walletProvider.confettiController.fire();
    await walletProvider.removePendingNostrRequest();
  }

  // ─── QR Content ───

  String _getActiveQrContent() {
    switch (_activeMode) {
      case QrMode.universal:
        return buildUnifiedUri(creqB: _creqB!, bolt11: _bolt11);
      case QrMode.cashu:
        return _creqB!.toUpperCase();
      case QrMode.lightning:
        return _bolt11?.toUpperCase() ?? '';
    }
  }

  // ─── Actions ───

  Future<void> _copyRequest() async {
    final content = _getActiveQrContent();
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.copiedToClipboard),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleNfc() {
    if (_nfcEmulating) {
      NfcService.stopEmulating();
      setState(() => _nfcEmulating = false);
    } else {
      NfcService.startEmulating(_getActiveQrContent());
      setState(() => _nfcEmulating = true);
    }
  }

  void _updateNfcPayload() {
    if (_nfcEmulating) {
      NfcService.startEmulating(_getActiveQrContent());
    }
  }

  void _shareRequest() async {
    final content = _getActiveQrContent();
    final formattedAmount =
        UnitFormatter.formatBalance(_amount, _activeUnit);
    final unitLabel = UnitFormatter.getUnitLabel(_activeUnit);

    await SharePlus.instance.share(
      ShareParams(
        text: '$formattedAmount $unitLabel\n\n$content',
        subject: 'Payment Request - $formattedAmount $unitLabel',
      ),
    );
  }
}
