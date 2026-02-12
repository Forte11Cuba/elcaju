import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/incoming_data_parser.dart' hide TokenInfo;
import '../../core/utils/nostr_utils.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/effects/cashu_confetti.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/p2pk_provider.dart';
import '../10_scanner/scan_screen.dart';

/// Pantalla para recibir tokens Cashu
class ReceiveScreen extends StatefulWidget {
  /// Token inicial (pre-cargado desde QR scanner o deep link)
  final String? initialToken;

  const ReceiveScreen({super.key, this.initialToken});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final CashuConfettiController _confettiController = CashuConfettiController();

  // Estado del token
  bool _isValidToken = false;
  bool _isProcessing = false;
  bool _showSuccess = false;
  BigInt _receivedAmount = BigInt.zero;
  String? _receivedUnit; // Se asigna al reclamar desde walletProvider.activeUnit
  TokenInfo? _tokenInfo;
  String? _errorMessage;

  // Estado P2PK
  bool _isP2PKLocked = false;
  bool _isLockedToUs = false;
  String? _lockedToPubkeyHex;
  String? _matchingKeyLabel; // Label de nuestra clave si coincide
  final TextEditingController _manualKeyController = TextEditingController();
  bool _showManualKey = false; // Toggle para mostrar/ocultar nsec
  String? _manualKeyError;

  @override
  void initState() {
    super.initState();
    // Pre-cargar token inicial si existe
    if (widget.initialToken != null && widget.initialToken!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tokenController.text = widget.initialToken!;
        _onTokenChanged(widget.initialToken!);
      });
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _manualKeyController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CashuConfetti(
      controller: _confettiController,
      child: GradientBackground(
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
              L10n.of(context)!.receiveCashu,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: _showSuccess ? _buildSuccessView() : _buildReceiveForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiveForm() {
    final l10n = L10n.of(context)!;
    return Column(
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
                  l10n.pasteTheCashuToken,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                // Campo de texto para el token
                _buildTokenInput(),

                const SizedBox(height: AppDimensions.paddingMedium),

                // Botones pegar y escanear
                _buildActionButtons(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Preview del token (si es válido)
                if (_isValidToken && _tokenInfo != null) _buildTokenPreview(),

                // Indicador P2PK (si el token está bloqueado)
                if (_isValidToken && _isP2PKLocked) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
                  _buildP2PKIndicator(),
                ],

                // Mensaje de error (si hay)
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),

        // Botón único "Recibir" (fijo abajo)
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: _buildReceiveButton(),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Icono de éxito
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.success,
              size: 50,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),

          // Monto recibido
          Builder(
            builder: (context) {
              final unit = _receivedUnit ?? context.read<WalletProvider>().activeUnit;
              return Text(
                '+${UnitFormatter.formatBalance(_receivedAmount, unit)} ${UnitFormatter.getUnitLabel(unit)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          Text(
            L10n.of(context)!.tokensReceived,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Botón volver (fijo abajo)
          PrimaryButton(
            text: L10n.of(context)!.backToHome,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenInput() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: TextField(
        controller: _tokenController,
        maxLines: 5,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'cashuA...',
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppDimensions.paddingSmall),
        ),
        onChanged: _onTokenChanged,
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
        builder: (context) => const ScanScreen(mode: ScanMode.cashuOnly),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      _tokenController.text = result;
      _onTokenChanged(result);
    }
  }

  Widget _buildTokenPreview() {
    final walletProvider = context.read<WalletProvider>();
    final amount = _tokenInfo!.amount;
    // Usar unidad detectada del token, o fallback a unidad activa
    final tokenUnit = _tokenInfo!.unit ?? walletProvider.activeUnit;
    final mintDisplay = UnitFormatter.getMintDisplayName(_tokenInfo!.mintUrl);
    final unitDetected = _tokenInfo!.unit != null;

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
                L10n.of(context)!.validToken,
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

          // Monto con unidad detectada
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
              Row(
                children: [
                  Text(
                    '${UnitFormatter.formatBalance(amount, tokenUnit)} ${UnitFormatter.getUnitLabel(tokenUnit)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Indicador si la unidad fue detectada automáticamente
                  if (!unitDetected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      LucideIcons.helpCircle,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                L10n.of(context)!.mint,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              Flexible(
                child: Text(
                  mintDisplay,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
          Icon(
            LucideIcons.alertCircle,
            color: AppColors.error,
            size: 20,
          ),
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

  /// Widget que muestra el estado P2PK del token
  Widget _buildP2PKIndicator() {
    final l10n = L10n.of(context)!;

    // Convertir pubkey hex a npub para mostrar
    String? npubDisplay;
    if (_lockedToPubkeyHex != null) {
      try {
        npubDisplay = NostrUtils.hexToNpub(_lockedToPubkeyHex!);
      } catch (_) {
        npubDisplay = _lockedToPubkeyHex; // Fallback a hex si falla conversión
      }
    }

    // Truncar npub para display: npub1abc...xyz
    String truncatedNpub = '';
    if (npubDisplay != null && npubDisplay.length > 20) {
      truncatedNpub = '${npubDisplay.substring(0, 12)}...${npubDisplay.substring(npubDisplay.length - 6)}';
    } else {
      truncatedNpub = npubDisplay ?? '';
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con icono y estado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isLockedToUs
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.warning.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isLockedToUs ? LucideIcons.unlock : LucideIcons.lock,
                  color: _isLockedToUs ? AppColors.success : AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isLockedToUs ? l10n.p2pkLockedToYou : l10n.p2pkLockedToOther,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isLockedToUs ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    if (_isLockedToUs && _matchingKeyLabel != null)
                      Text(
                        _matchingKeyLabel!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Badge experimental
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.flaskConical,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.p2pkExperimentalShort,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Pubkey (npub truncado) - tap para copiar
          GestureDetector(
            onTap: () {
              if (npubDisplay != null) {
                Clipboard.setData(ClipboardData(text: npubDisplay));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.copied('npub')),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      truncatedNpub,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.copy,
                    size: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),

          // Campo nsec manual (solo si NO es nuestra clave)
          if (!_isLockedToUs) ...[
            const SizedBox(height: 16),

            // Mensaje de error si no puede desbloquear
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.p2pkCannotUnlock,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Campo para ingresar nsec manualmente
            Text(
              l10n.p2pkEnterPrivateKey,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _manualKeyError != null
                      ? AppColors.error.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualKeyController,
                      obscureText: !_showManualKey,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'nsec1... o hex',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _manualKeyError = null;
                        });
                      },
                    ),
                  ),
                  // Botón mostrar/ocultar
                  IconButton(
                    icon: Icon(
                      _showManualKey ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showManualKey = !_showManualKey;
                      });
                    },
                  ),
                  // Botón pegar
                  IconButton(
                    icon: Icon(
                      LucideIcons.clipboard,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () async {
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData?.text != null) {
                        _manualKeyController.text = clipboardData!.text!.trim();
                        setState(() {
                          _manualKeyError = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // Error de clave manual
            if (_manualKeyError != null) ...[
              const SizedBox(height: 8),
              Text(
                _manualKeyError!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReceiveButton() {
    final l10n = L10n.of(context)!;

    // Determinar si el botón debe estar habilitado
    bool canReceive = _isValidToken && !_isProcessing;

    // Si es P2PK y NO es nuestra clave, necesita nsec manual válido
    if (_isP2PKLocked && !_isLockedToUs) {
      final manualKey = _manualKeyController.text.trim();
      canReceive = canReceive && manualKey.isNotEmpty;
    }

    return PrimaryButton(
      text: _isProcessing ? l10n.claiming : l10n.receive,
      onPressed: canReceive ? _receiveToken : null,
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _tokenController.text = clipboardData!.text!.trim();
      _onTokenChanged(clipboardData.text!.trim());
    }
  }

  void _onTokenChanged(String value) {
    final walletProvider = context.read<WalletProvider>();
    final p2pkProvider = context.read<P2PKProvider>();

    setState(() {
      _errorMessage = null;
      _manualKeyError = null;

      // Reset P2PK state
      _isP2PKLocked = false;
      _isLockedToUs = false;
      _lockedToPubkeyHex = null;
      _matchingKeyLabel = null;

      if (value.isEmpty) {
        _isValidToken = false;
        _tokenInfo = null;
        return;
      }

      // Parsear token real con cdk-flutter
      final tokenInfo = walletProvider.parseToken(value.trim());

      if (tokenInfo != null) {
        _isValidToken = true;
        _tokenInfo = tokenInfo;

        // Detectar P2PK
        _isP2PKLocked = p2pkProvider.isTokenLocked(value.trim());
        if (_isP2PKLocked) {
          _lockedToPubkeyHex = p2pkProvider.extractLockedPubkey(value.trim());
          _isLockedToUs = p2pkProvider.isTokenLockedToUs(value.trim());

          // Si es nuestra, buscar el label de la clave
          if (_isLockedToUs && _lockedToPubkeyHex != null) {
            _matchingKeyLabel = _findMatchingKeyLabel(p2pkProvider);
          }
        }
      } else {
        _isValidToken = false;
        _tokenInfo = null;
        _errorMessage = L10n.of(context)!.invalidToken;
      }
    });
  }

  /// Busca el label de la clave que coincide con el token P2PK
  String? _findMatchingKeyLabel(P2PKProvider p2pkProvider) {
    if (_lockedToPubkeyHex == null) return null;

    // Normalizar a x-only para comparar
    final lockedNormalized = _normalizeToXOnly(_lockedToPubkeyHex!);

    for (final key in p2pkProvider.keys) {
      final keyNormalized = _normalizeToXOnly(key.publicKey);
      if (keyNormalized == lockedNormalized) {
        return key.label;
      }
    }
    return null;
  }

  /// Normaliza pubkey a x-only (64 chars) quitando prefijo SEC1 si existe
  String _normalizeToXOnly(String pubkey) {
    final lower = pubkey.toLowerCase();
    if (lower.length == 66 && (lower.startsWith('02') || lower.startsWith('03'))) {
      return lower.substring(2);
    }
    return lower;
  }

  /// Método principal: recibe token con detección automática de conectividad.
  /// 1. Si el mint es desconocido y no hay conexión → rechazar
  /// 2. Ping al mint (3s) → si OK → claim → si falla → guardar pendiente
  Future<void> _receiveToken() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final l10n = L10n.of(context)!;
    final walletProvider = context.read<WalletProvider>();

    try {
      final mintUrl = _tokenInfo?.mintUrl;
      if (mintUrl == null) {
        throw Exception(l10n.invalidToken);
      }

      // Verificar si el mint es conocido
      final isKnownMint = walletProvider.mintUrls.contains(mintUrl);

      // Verificar conectividad al mint
      final canReach = await walletProvider.canReachMint(mintUrl);

      // Si el mint es desconocido y no hay conexión → rechazar
      if (!isKnownMint && !canReach) {
        setState(() {
          _errorMessage = l10n.unknownMintOffline;
          _isProcessing = false;
        });
        return;
      }

      // Si no hay conexión → guardar como pendiente
      if (!canReach) {
        await _saveForLaterOffline();
        return;
      }

      // Hay conexión → intentar reclamar
      await _claimToken();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.claimError(e.toString());
        _isProcessing = false;
      });
    }
  }

  /// Guarda el token como pendiente cuando no hay conexión.
  Future<void> _saveForLaterOffline() async {
    final l10n = L10n.of(context)!;
    final walletProvider = context.read<WalletProvider>();

    try {
      final pending = await walletProvider.addPendingToken(
        _tokenController.text.trim(),
      );

      if (pending != null) {
        if (mounted) {
          // Mostrar mensaje de sin conexión
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noConnectionTokenSaved),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Límite alcanzado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pendingTokenLimitReached),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveTokenError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Reclama el token directamente (cuando hay conexión).
  Future<void> _claimToken() async {
    final walletProvider = context.read<WalletProvider>();
    final p2pkProvider = context.read<P2PKProvider>();
    final l10n = L10n.of(context)!;

    // Guardar unidad detectada del token ANTES de reclamar
    final detectedUnit = _tokenInfo?.unit ?? walletProvider.activeUnit;
    final token = _tokenController.text.trim();

    try {
      BigInt amountReceived;

      if (_isP2PKLocked) {
        // Token P2PK - necesita clave privada para desbloquear
        String? privateKeyHex;

        if (_isLockedToUs) {
          // Es nuestra clave - obtener automáticamente
          privateKeyHex = p2pkProvider.getPrivateKeyForToken(token);
          if (privateKeyHex == null) {
            throw Exception(l10n.p2pkCannotUnlock);
          }
        } else {
          // No es nuestra - usar clave manual
          final manualInput = _manualKeyController.text.trim();

          // Intentar convertir nsec a hex
          if (manualInput.startsWith('nsec1')) {
            privateKeyHex = NostrUtils.nsecToHex(manualInput);
          } else if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(manualInput)) {
            // Ya es hex de 64 caracteres
            privateKeyHex = manualInput.toLowerCase();
          }

          if (privateKeyHex == null) {
            setState(() {
              _manualKeyError = l10n.p2pkInvalidPrivateKey;
              _isProcessing = false;
            });
            return;
          }
        }

        // Reclamar token P2PK
        amountReceived = await walletProvider.receiveP2pkToken(
          token,
          [privateKeyHex],
        );
      } else {
        // Token normal - flujo existente
        amountReceived = await walletProvider.receiveToken(token);
      }

      if (mounted) {
        setState(() {
          _receivedAmount = amountReceived;
          _receivedUnit = detectedUnit;
          _showSuccess = true;
          _isProcessing = false;
        });

        // Disparar confetti
        _confettiController.fire();
      }
    } catch (e) {
      if (!mounted) return;
      // Mensajes de error más amigables
      final errorStr = e.toString().toLowerCase();
      String errorMessage;
      if (errorStr.contains('already spent') || errorStr.contains('token already')) {
        errorMessage = l10n.tokenAlreadyClaimed;
      } else if (errorStr.contains('unknown mint') || errorStr.contains('mint not found')) {
        errorMessage = l10n.unknownMint;
      } else if (errorStr.contains('cannot unlock') || errorStr.contains('p2pk')) {
        errorMessage = l10n.p2pkCannotUnlock;
      } else {
        errorMessage = l10n.claimError(e.toString());
      }
      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
      });
    }
  }
}
