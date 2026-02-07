import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/effects/cashu_confetti.dart';
import '../../providers/wallet_provider.dart';

/// Pantalla para recibir tokens Cashu
class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

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

  @override
  void dispose() {
    _tokenController.dispose();
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
            title: const Text(
              'Recibir Cashu',
              style: TextStyle(
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
                  'Pega el token Cashu:',
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

                // Botón pegar del portapapeles
                _buildPasteButton(),

                const SizedBox(height: AppDimensions.paddingLarge),

                // Preview del token (si es válido)
                if (_isValidToken && _tokenInfo != null) _buildTokenPreview(),

                // Mensaje de error (si hay)
                if (_errorMessage != null) _buildErrorMessage(),
              ],
            ),
          ),
        ),

        // Botón reclamar (fijo abajo)
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: _buildClaimButton(),
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
            'Tokens recibidos',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // Botón volver (fijo abajo)
          PrimaryButton(
            text: 'Volver al inicio',
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
                'Token válido',
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
                'Monto:',
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
                'Mint:',
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

  Widget _buildClaimButton() {
    return PrimaryButton(
      text: _isProcessing ? 'Reclamando...' : 'Reclamar tokens',
      onPressed: _isValidToken && !_isProcessing ? _claimToken : null,
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

    setState(() {
      _errorMessage = null;

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
      } else {
        _isValidToken = false;
        _tokenInfo = null;
        _errorMessage = 'Token inválido o malformado';
      }
    });
  }

  Future<void> _claimToken() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      // Guardar unidad detectada del token ANTES de reclamar
      final detectedUnit = _tokenInfo?.unit ?? walletProvider.activeUnit;

      // Reclamar token (usa unidad detectada internamente)
      final amountReceived = await walletProvider.receiveToken(
        _tokenController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _receivedAmount = amountReceived;
          _receivedUnit = detectedUnit; // Usar unidad del token
          _showSuccess = true;
          _isProcessing = false;
        });

        // Disparar confetti
        _confettiController.fire();
      }
    } catch (e) {
      setState(() {
        // Mensajes de error más amigables
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('already spent') || errorStr.contains('token already')) {
          _errorMessage = 'Este token ya fue reclamado';
        } else if (errorStr.contains('unknown mint') || errorStr.contains('mint not found')) {
          _errorMessage = 'Token de un mint desconocido';
        } else {
          _errorMessage = 'Error al reclamar: $e';
        }
      });
    } finally {
      if (mounted && !_showSuccess) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
