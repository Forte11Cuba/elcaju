import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';

/// Pantalla de selección de idioma
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  // Lista de idiomas ordenados por prioridad
  static const List<_LanguageData> _languages = [
    _LanguageData(code: 'es', flag: '🇪🇸'),
    _LanguageData(code: 'en', flag: '🇬🇧'),
    _LanguageData(code: 'pt', flag: '🇵🇹'),
    _LanguageData(code: 'fr', flag: '🇫🇷'),
    _LanguageData(code: 'it', flag: '🇮🇹'),
    _LanguageData(code: 'de', flag: '🇩🇪'),
    _LanguageData(code: 'ru', flag: '🇷🇺'),
    _LanguageData(code: 'zh', flag: '🇨🇳'),
    _LanguageData(code: 'ja', flag: '🇯🇵'),
    _LanguageData(code: 'ko', flag: '🇰🇷'),
    _LanguageData(code: 'sw', flag: '🇰🇪'),
  ];

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
            l10n.language,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  final isSelected = settingsProvider.locale == lang.code;
                  final name = _getLanguageName(context, lang.code);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLanguageTile(
                      context: context,
                      settingsProvider: settingsProvider,
                      code: lang.code,
                      name: name,
                      flag: lang.flag,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required SettingsProvider settingsProvider,
    required String code,
    required String name,
    required String flag,
    required bool isSelected,
  }) {
    return GlassCard(
      onTap: () => _selectLanguage(context, settingsProvider, code, name),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          // Bandera
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                flag,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          // Nombre del idioma
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          // Indicador de selección
          if (isSelected)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryAction,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.check,
                color: Colors.white,
                size: 14,
              ),
            )
          else
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getLanguageName(BuildContext context, String code) {
    final l10n = L10n.of(context)!;
    switch (code) {
      case 'es':
        return l10n.spanish;
      case 'en':
        return l10n.english;
      case 'pt':
        return l10n.portuguese;
      case 'fr':
        return l10n.french;
      case 'de':
        return l10n.german;
      case 'it':
        return l10n.italian;
      case 'ru':
        return l10n.russian;
      case 'zh':
        return l10n.chinese;
      case 'ja':
        return l10n.japanese;
      case 'ko':
        return l10n.korean;
      case 'sw':
        return l10n.swahili;
      default:
        return l10n.spanish;
    }
  }

  Future<void> _selectLanguage(
    BuildContext context,
    SettingsProvider settingsProvider,
    String code,
    String name,
  ) async {
    await settingsProvider.setLocale(code);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.languageChanged(name)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

/// Datos de cada idioma
class _LanguageData {
  final String code;
  final String flag;

  const _LanguageData({
    required this.code,
    required this.flag,
  });
}
