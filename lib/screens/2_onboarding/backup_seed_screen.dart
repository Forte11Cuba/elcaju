import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_card.dart';

/// Pantalla de backup de la frase semilla
class BackupSeedScreen extends StatefulWidget {
  final String mnemonic;
  final bool isFromSettings;

  const BackupSeedScreen({
    super.key,
    required this.mnemonic,
    this.isFromSettings = false,
  });

  @override
  State<BackupSeedScreen> createState() => _BackupSeedScreenState();
}

class _BackupSeedScreenState extends State<BackupSeedScreen> {
  bool _revealed = false;
  bool _confirmed = false;

  List<String> get _words => widget.mnemonic.split(' ');

  void _copyToClipboard(L10n l10n) {
    Clipboard.setData(ClipboardData(text: widget.mnemonic));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.seedCopied),
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
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
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            l10n.backupTitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.seedPhraseTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                Text(
                  l10n.seedPhraseDescription,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                Expanded(
                  child: GlassCard(
                    child: Column(
                      children: [
                        Expanded(
                          child: _revealed
                              ? _buildWordsGrid()
                              : _buildHiddenView(l10n),
                        ),
                        if (_revealed) ...[
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: AppDimensions.paddingMedium),
                          GestureDetector(
                            onTap: () => _copyToClipboard(l10n),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.copy,
                                  color: AppColors.textSecondary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.copyToClipboard,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                if (_revealed)
                  GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertTriangle,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            l10n.neverShareSeed,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimensions.paddingLarge),

                if (_revealed && !widget.isFromSettings)
                  GestureDetector(
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _confirmed
                                ? AppColors.success
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _confirmed
                                  ? AppColors.success
                                  : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: _confirmed
                              ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            l10n.confirmBackup,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimensions.paddingMedium),

                if (!_revealed)
                  PrimaryButton(
                    text: l10n.revealSeedPhrase,
                    icon: LucideIcons.eye,
                    onPressed: () => setState(() => _revealed = true),
                  )
                else
                  PrimaryButton(
                    text: widget.isFromSettings ? 'Volver' : l10n.continue_,
                    onPressed: (widget.isFromSettings || _confirmed)
                        ? () => Navigator.pop(context)
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenView(L10n l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.eyeOff,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            l10n.tapToReveal,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWordsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.deepVoidPurple.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${index + 1}. ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                  TextSpan(
                    text: _words[index],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
