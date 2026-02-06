import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Tipos de botón según la importancia de la acción
/// La intensidad del efecto = importancia de la acción
enum ButtonType {
  /// Acciones críticas que mueven dinero (Enviar)
  /// Efecto más fuerte: heavyImpact, scale 0.95, delay 100ms
  criticalAction,

  /// Acciones importantes pero seguras (Recibir)
  /// Efecto medio: mediumImpact, scale 0.97, sin delay
  primaryAction,

  /// Acciones de navegación (Historial)
  /// Efecto sutil: lightImpact, scale 0.98, sin delay
  navigation,
}

/// Botón animado con feedback táctil y visual premium
///
/// Diferencia la intensidad del efecto según el tipo de acción:
/// - [ButtonType.criticalAction]: Para acciones que mueven dinero
/// - [ButtonType.primaryAction]: Para acciones importantes pero seguras
/// - [ButtonType.navigation]: Para navegación simple
///
/// Ejemplo de uso:
/// ```dart
/// AnimatedActionButton(
///   label: 'Enviar',
///   type: ButtonType.criticalAction,
///   onTap: () => _handleSend(),
/// )
/// ```
class AnimatedActionButton extends StatefulWidget {
  /// Texto del botón
  final String label;

  /// Callback al tocar (se ejecuta después del micro-delay si aplica)
  final VoidCallback onTap;

  /// Tipo de botón que determina la intensidad del efecto
  final ButtonType type;

  /// Gradiente opcional (para botones primarios)
  /// Si es null y backgroundColor también, usa el gradiente por defecto
  final Gradient? gradient;

  /// Color de fondo opcional (para botones de navegación)
  /// Se ignora si gradient está definido
  final Color? backgroundColor;

  /// Icono opcional antes del texto
  final IconData? icon;

  /// Si mostrar el icono (default: false)
  final bool showIcon;

  /// Ancho del botón (default: expandir al padre)
  final double? width;

  /// Alto del botón (default: según tipo)
  final double? height;

  const AnimatedActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.type,
    this.gradient,
    this.backgroundColor,
    this.icon,
    this.showIcon = false,
    this.width,
    this.height,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  /// Controller para animaciones coordinadas
  late AnimationController _controller;

  /// Animación de escala
  late Animation<double> _scaleAnimation;

  /// Animación de offset de sombra
  late Animation<double> _shadowOffsetAnimation;

  /// Animación de blur de sombra
  late Animation<double> _shadowBlurAnimation;

  /// Animación de opacidad de sombra
  late Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Duración de la animación: 150ms para sentirse responsivo
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // Configurar animaciones según el tipo de botón
    _setupAnimations();
  }

  void _setupAnimations() {
    // Curve suave para salida (easeOutCubic da sensación premium)
    const curve = Curves.easeOutCubic;

    // === ESCALA ===
    // Intensidad según tipo: crítico se hunde más, navegación casi imperceptible
    final double targetScale = switch (widget.type) {
      ButtonType.criticalAction => 0.95, // Se hunde más - acción crítica
      ButtonType.primaryAction => 0.97,  // Se hunde menos
      ButtonType.navigation => 0.98,     // Muy sutil - solo navegación
    };

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: targetScale,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // === SOMBRA ===
    // Los valores de sombra también varían según tipo
    final (normalOffset, pressedOffset) = switch (widget.type) {
      ButtonType.criticalAction => (6.0, 2.0),
      ButtonType.primaryAction => (6.0, 2.0),
      ButtonType.navigation => (4.0, 1.0),
    };

    final (normalBlur, pressedBlur) = switch (widget.type) {
      ButtonType.criticalAction => (12.0, 4.0),
      ButtonType.primaryAction => (12.0, 4.0),
      ButtonType.navigation => (8.0, 3.0),
    };

    final (normalOpacity, pressedOpacity) = switch (widget.type) {
      ButtonType.criticalAction => (0.4, 0.15),
      ButtonType.primaryAction => (0.3, 0.1),
      ButtonType.navigation => (0.2, 0.1),
    };

    _shadowOffsetAnimation = Tween<double>(
      begin: normalOffset,
      end: pressedOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _shadowBlurAnimation = Tween<double>(
      begin: normalBlur,
      end: pressedBlur,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _shadowOpacityAnimation = Tween<double>(
      begin: normalOpacity,
      end: pressedOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
  }

  @override
  void didUpdateWidget(AnimatedActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reconfigurar si cambia el tipo
    if (oldWidget.type != widget.type) {
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Trigger haptic feedback según tipo de acción
  void _triggerHaptic() {
    switch (widget.type) {
      case ButtonType.criticalAction:
        // Acción crítica - mueve dinero - feedback fuerte
        HapticFeedback.heavyImpact();
        break;
      case ButtonType.primaryAction:
        // Acción importante pero segura - feedback medio
        HapticFeedback.mediumImpact();
        break;
      case ButtonType.navigation:
        // Solo navegación - feedback sutil
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Delay después del tap según tipo
  /// Solo acciones críticas tienen micro-delay (sensación de "peso")
  Duration get _callbackDelay {
    return widget.type == ButtonType.criticalAction
        ? const Duration(milliseconds: 100)
        : Duration.zero;
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    // Haptic inmediato al tocar
    _triggerHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();

    // Ejecutar callback después del delay según tipo
    Future.delayed(_callbackDelay, () {
      widget.onTap();
    });
  }

  void _handleTapCancel() {
    // Revertir animación sin ejecutar callback
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Determinar si es botón con gradiente o con color sólido
    final bool isGradientButton = widget.type != ButtonType.navigation;

    // Gradiente por defecto para botones primarios
    final effectiveGradient = widget.gradient ??
        (isGradientButton
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: AppColors.buttonGradient,
              )
            : null);

    // Color de fondo para botón de navegación (glass effect)
    final effectiveBackgroundColor = widget.backgroundColor ??
        (!isGradientButton
            ? AppColors.glassBase.withValues(alpha: AppColors.glassOpacity)
            : null);

    // Color de sombra según tipo
    final shadowColor = isGradientButton
        ? AppColors.primaryAction
        : Colors.black;

    // Altura según tipo
    final effectiveHeight = widget.height ??
        (widget.type == ButtonType.navigation
            ? AppDimensions.buttonHeight + 4
            : AppDimensions.buttonHeight);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: effectiveHeight,
              decoration: BoxDecoration(
                // Gradiente o color sólido
                gradient: effectiveGradient,
                color: effectiveGradient == null ? effectiveBackgroundColor : null,
                borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
                // Borde para botones de navegación (glass effect)
                border: !isGradientButton
                    ? Border.all(
                        color: Colors.white.withValues(alpha: AppColors.glassBorderOpacity),
                        width: 1,
                      )
                    : null,
                // Sombra animada
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: _shadowOpacityAnimation.value),
                    blurRadius: _shadowBlurAnimation.value,
                    offset: Offset(0, _shadowOffsetAnimation.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono opcional
              if (widget.showIcon && widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.type == ButtonType.navigation ? 28 : 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
              ],
              // Texto
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: widget.type == ButtonType.navigation ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
