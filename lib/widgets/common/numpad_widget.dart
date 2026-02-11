import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';

/// Callback cuando el valor cambia
typedef NumpadCallback = void Function(String value);

/// Teclado numérico reutilizable
class NumpadWidget extends StatelessWidget {
  /// Valor actual
  final String value;

  /// Callback cuando el valor cambia
  final NumpadCallback onChanged;

  /// Máximo de dígitos permitidos
  final int maxDigits;

  /// Mostrar botón MAX (para enviar todo el balance)
  final bool showMaxButton;

  /// Callback para botón MAX
  final VoidCallback? onMaxPressed;

  const NumpadWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxDigits = 12,
    this.showMaxButton = false,
    this.onMaxPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Detectar si es móvil
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final verticalSpacing = isMobile ? 8.0 : 12.0;
    final horizontalSpacing = isMobile ? 8.0 : 12.0;
    final containerPadding = isMobile ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: containerPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1: 1, 2, 3, del
          _buildRow(['1', '2', '3', 'del'], horizontalSpacing, isMobile),
          SizedBox(height: verticalSpacing),
          // Fila 2: 4, 5, 6, 00
          _buildRow(['4', '5', '6', '00'], horizontalSpacing, isMobile),
          SizedBox(height: verticalSpacing),
          // Fila 3: 7, 8, 9, 000
          _buildRow(['7', '8', '9', '000'], horizontalSpacing, isMobile),
          SizedBox(height: verticalSpacing),
          // Fila 4: MAX/vacío, 0, vacío, C
          _buildRow([showMaxButton ? 'MAX' : '', '0', '', 'C'], horizontalSpacing, isMobile),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, double spacing, bool isMobile) {
    final List<Widget> children = [];

    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: spacing));
      }

      if (keys[i].isEmpty) {
        children.add(Expanded(child: Container()));
      } else {
        children.add(Expanded(
          child: _buildKey(keys[i], isMobile),
        ));
      }
    }

    return Row(children: children);
  }

  Widget _buildKey(String key, bool isMobile) {
    final isDelete = key == 'del';
    final isClear = key == 'C';
    final isMax = key == 'MAX';
    final isZeroShortcut = key == '00' || key == '000';

    final buttonHeight = isMobile ? 48.0 : 56.0;

    Color bgColor;
    Color textColor;

    if (isDelete || isClear) {
      bgColor = Colors.white.withValues(alpha: 0.08);
      textColor = isClear ? AppColors.error : AppColors.textSecondary;
    } else if (isZeroShortcut || isMax) {
      bgColor = AppColors.primaryAction.withValues(alpha: 0.15);
      textColor = AppColors.primaryAction;
    } else {
      bgColor = Colors.white.withValues(alpha: 0.05);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _onKeyPress(key),
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isDelete
              ? Icon(
                  LucideIcons.delete,
                  color: textColor,
                  size: isMobile ? 20 : 24,
                )
              : Text(
                  key,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: (isZeroShortcut || isMax)
                        ? (isMobile ? 16 : 18)
                        : (isMobile ? 24 : 28),
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }

  void _onKeyPress(String key) {
    String newValue = value;

    if (key == 'del') {
      if (newValue.isNotEmpty) {
        newValue = newValue.substring(0, newValue.length - 1);
      }
    } else if (key == 'C') {
      newValue = '';
    } else if (key == 'MAX') {
      onMaxPressed?.call();
      return;
    } else if (key == '00') {
      if (newValue.isNotEmpty && newValue != '0') {
        newValue += '00';
      } else if (newValue.isEmpty) {
        newValue = '0';
      }
    } else if (key == '000') {
      if (newValue.isNotEmpty && newValue != '0') {
        newValue += '000';
      } else if (newValue.isEmpty) {
        newValue = '0';
      }
    } else {
      if (newValue == '0' && key == '0') return;
      if (newValue == '0' && key != '0') {
        newValue = key;
      } else {
        newValue += key;
      }
    }

    if (newValue.length > maxDigits) {
      newValue = newValue.substring(0, maxDigits);
    }

    onChanged(newValue);
  }
}
