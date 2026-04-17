import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// Frame común para modales tipo bottom sheet.
///
/// Aplica SafeArea(top: false) para que los botones internos no queden
/// tapados por la barra de navegación del sistema (gestos o 3 botones).
///
/// Usá [respectKeyboard]: true cuando el modal contenga TextField, para
/// combinar el inset de la barra con el del teclado (viewInsets.bottom).
class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool respectKeyboard;

  const BottomSheetContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.paddingMedium),
    this.respectKeyboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // viewPadding.bottom es el inset crudo de la nav bar del sistema
    // (no se consume aunque un SafeArea padre ya lo haya absorbido).
    final navBarInset = mq.viewPadding.bottom;

    // Combinar el padding base con el extra del navBar abajo.
    final resolvedPadding = padding.resolve(Directionality.of(context));
    final effectivePadding = EdgeInsets.only(
      left: resolvedPadding.left,
      top: resolvedPadding.top,
      right: resolvedPadding.right,
      bottom: resolvedPadding.bottom + navBarInset,
    );

    final frame = Container(
      decoration: BoxDecoration(
        color: AppColors.deepVoidPurple,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(padding: effectivePadding, child: child),
    );

    if (respectKeyboard) {
      return Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: frame,
      );
    }
    return frame;
  }
}

/// Handle visual en la parte superior del modal (la barrita).
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
