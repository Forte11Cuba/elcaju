import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/bottom_sheet_container.dart';
import '../../widgets/common/secondary_button.dart';

/// Modal para confirmar borrado de wallet
class DeleteWalletModal extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeleteWalletModal({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<DeleteWalletModal> createState() => _DeleteWalletModalState();
}

class _DeleteWalletModalState extends State<DeleteWalletModal> {
  final TextEditingController _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final confirmWord = l10n.deleteConfirmWord;
    return BottomSheetContainer(
      respectKeyboard: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),

          // Icono advertencia
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.alertTriangle,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Título
          Text(
            l10n.deleteWalletQuestion,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Advertencia
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.actionIrreversible,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.deleteWalletWarning,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.error.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Input de confirmación
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.typeDeleteToConfirm,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: confirmWord,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _canDelete = value == confirmWord;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Botones
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: l10n.cancel,
                  onPressed: widget.onCancel,
                  height: 52,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: _DestructiveButton(
                  text: l10n.deleteWallet,
                  enabled: _canDelete,
                  onPressed: widget.onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón destructivo con semantics accesibles.
/// Separado de los botones estándar porque la acción es irreversible.
class _DestructiveButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  const _DestructiveButton({
    required this.text,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: SizedBox(
        height: 52,
        child: Material(
          color: enabled
              ? AppColors.error
              : AppColors.error.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
