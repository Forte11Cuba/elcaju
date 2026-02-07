import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cdk_flutter/cdk_flutter.dart' as cdk;
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

/// Pantalla para compartir el token Cashu generado
class ShareTokenScreen extends StatefulWidget {
  final String token;
  final BigInt amount;
  final String unit;
  final String? memo;

  const ShareTokenScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.unit,
    this.memo,
  });

  @override
  State<ShareTokenScreen> createState() => _ShareTokenScreenState();
}

class _ShareTokenScreenState extends State<ShareTokenScreen> {
  List<String> _urFragments = [];
  int _currentFragment = 0;
  Timer? _animationTimer;

  // Configuración de velocidad (como cashu.me)
  static const int _intervalFast = 100;    // ms
  static const int _intervalMedium = 200;  // ms
  static const int _intervalSlow = 400;    // ms
  int _currentInterval = _intervalMedium;
  String _speedLabel = 'M';

  @override
  void initState() {
    super.initState();
    _encodeTokenToUR();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _encodeTokenToUR() {
    // Parsear el token string a objeto Token de cdk-flutter
    final token = cdk.Token.parse(encoded: widget.token);

    // Codificar a fragmentos UR usando cdk-flutter
    // maxFragmentLength por defecto es 150 bytes
    _urFragments = cdk.encodeQrToken(token: token);

    // Si hay múltiples fragmentos, iniciar animación
    if (_urFragments.length > 1) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      Duration(milliseconds: _currentInterval),
      (timer) {
        if (mounted) {
          setState(() {
            _currentFragment = (_currentFragment + 1) % _urFragments.length;
          });
        }
      },
    );
  }

  void _cycleSpeed() {
    setState(() {
      if (_currentInterval == _intervalMedium) {
        _currentInterval = _intervalSlow;
        _speedLabel = 'S';
      } else if (_currentInterval == _intervalSlow) {
        _currentInterval = _intervalFast;
        _speedLabel = 'F';
      } else {
        _currentInterval = _intervalMedium;
        _speedLabel = 'M';
      }
    });
    // Reiniciar timer con nueva velocidad
    if (_urFragments.length > 1) {
      _startAnimation();
    }
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
            icon: const Icon(LucideIcons.x, color: Colors.white),
            onPressed: () => _goToHome(context),
          ),
          title: const Text(
            'Token creado',
            style: TextStyle(
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
                    children: [
                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Icono de exito
                      _buildSuccessIcon(),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Monto
                      _buildAmountDisplay(),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // QR del token (dinámico si hay múltiples fragmentos)
                      _buildQRDisplay(),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Token truncado
                      _buildTokenTextDisplay(),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Botones copiar y compartir
                      _buildActionButtons(context),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Advertencia
                      _buildWarning(),
                    ],
                  ),
                ),
              ),

              // Botón volver al inicio (fijo abajo)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: PrimaryButton(
                  text: 'Volver al inicio',
                  onPressed: () => _goToHome(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(LucideIcons.check, color: AppColors.success, size: 40),
    );
  }

  Widget _buildAmountDisplay() {
    final formattedAmount = UnitFormatter.formatBalance(widget.amount, widget.unit);
    final unitLabel = UnitFormatter.getUnitLabel(widget.unit);

    return Column(
      children: [
        Text(
          '$formattedAmount $unitLabel',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (widget.memo != null && widget.memo!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '"${widget.memo}"',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQRDisplay() {
    if (_urFragments.isEmpty) {
      return const SizedBox(
        width: 220,
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final size = 220.0;
    final isAnimated = _urFragments.length > 1;

    return Column(
      children: [
        // QR Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: _urFragments[_currentFragment],
                version: QrVersions.auto,
                size: size - 32,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
              ),
            ),
          ),
        ),

        // Controles de animación (solo si hay múltiples fragmentos)
        if (isAnimated) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicador de fragmento actual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentFragment + 1} / ${_urFragments.length}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón de velocidad
              GestureDetector(
                onTap: _cycleSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryAction.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.gauge,
                        color: AppColors.primaryAction,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _speedLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTokenTextDisplay() {
    final displayToken = widget.token.length > 50
        ? '${widget.token.substring(0, 25)}...${widget.token.substring(widget.token.length - 20)}'
        : widget.token;

    final isAnimated = _urFragments.length > 1;

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.bean, color: AppColors.primaryAction, size: 16),
              const SizedBox(width: 6),
              Text(
                isAnimated
                    ? 'Token Cashu (QR animado - ${_urFragments.length} fragmentos UR)'
                    : 'Token Cashu',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            displayToken,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Copiar
        Expanded(
          child: GestureDetector(
            onTap: () => _copyToken(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.copy, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Copiar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        // Compartir
        Expanded(
          child: GestureDetector(
            onTap: () => _shareToken(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.buttonGradient,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.share2, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Compartir',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Guarda este token hasta que el receptor lo reclame. Si lo pierdes, perderas los fondos.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToken(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.token));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Token copiado al portapapeles'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareToken(BuildContext context) async {
    final memo = widget.memo != null && widget.memo!.isNotEmpty
        ? '\n"${widget.memo}"'
        : '';

    final formattedAmount = UnitFormatter.formatBalance(widget.amount, widget.unit);
    final unitLabel = UnitFormatter.getUnitLabel(widget.unit);

    await SharePlus.instance.share(
      ShareParams(
        text: '$formattedAmount $unitLabel$memo\n\n${widget.token}',
        subject: 'Token Cashu - $formattedAmount $unitLabel',
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
