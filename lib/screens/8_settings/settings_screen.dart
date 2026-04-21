import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../2_onboarding/backup_seed_screen.dart';
import '../13_swap/swap_screen.dart';
import 'about_dialog.dart';
import 'delete_wallet_modal.dart';
import 'recover_tokens_modal.dart';
import 'pin_dialog.dart';
import 'mints_screen.dart';
import 'privacy_screen.dart';
import 'language_screen.dart';
import 'p2pk_keys_screen.dart';

/// Pantalla de configuración
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = info.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _appVersion = '—');
    }
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
            l10n.settings,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección WALLET
                    _buildSectionHeader(l10n.walletSection),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    _buildSettingTile(
                      icon: LucideIcons.arrowLeftRight,
                      title: l10n.swap,
                      subtitle: l10n.swapDescription,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SwapScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.landmark,
                      title: l10n.connectedMints,
                      subtitle: l10n.manageCashuMints,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MintsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.lock,
                      title: l10n.pinAccess,
                      subtitle: settingsProvider.pinEnabled
                          ? l10n.pinEnabled
                          : l10n.protectWithPin,
                      trailing: Switch(
                        value: settingsProvider.pinEnabled,
                        onChanged: (value) =>
                            _togglePin(context, settingsProvider, value),
                        activeThumbColor: AppColors.primaryAction,
                      ),
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.key,
                      title: l10n.backupSeedPhrase,
                      subtitle: l10n.viewRecoveryWords,
                      onTap: () => _showBackupSeed(context, settingsProvider),
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.searchCode,
                      title: l10n.recoverTokens,
                      subtitle: l10n.scanMintsWithSeed,
                      onTap: () => _showRecoverTokensModal(context),
                    ),
                    _buildP2PKTile(l10n),

                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sección IDIOMA
                    _buildSectionHeader(l10n.appearanceSection),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    _buildSettingTile(
                      icon: LucideIcons.globe,
                      title: l10n.language,
                      subtitle: _getLanguageName(settingsProvider.locale),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sección INFORMACIÓN
                    _buildSectionHeader(l10n.informationSection),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    _buildInfoTile(
                      icon: LucideIcons.tag,
                      title: l10n.version,
                      subtitle: _appVersion,
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.info,
                      title: l10n.about,
                      onTap: () => showElCajuAboutDialog(context, _appVersion),
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.shield,
                      title: l10n.privacyPolicy,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      ),
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.github,
                      title: 'GitHub',
                      onTap: () => _openGitHub(),
                    ),

                    const SizedBox(height: AppDimensions.paddingExtraLarge),

                    // Botón borrar wallet
                    _buildDangerButton(context, settingsProvider),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // WIDGETS DE UI
  // ============================================================

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing
          else
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildP2PKTile(L10n l10n) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const P2PKKeysScreen(),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.keyRound, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título con badge experimental
                Row(
                  children: [
                    Text(
                      l10n.p2pkTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.flaskConical,
                            color: AppColors.error,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.p2pkExperimentalShort,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Descripción normal
                Text(
                  l10n.p2pkSettingsDescription,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = L10n.of(context)!;
    return GestureDetector(
      onTap: () => _showDeleteWalletModal(context, settingsProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.deleteWallet,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================

  String _getLanguageName(String locale) {
    final l10n = L10n.of(context)!;
    switch (locale) {
      case 'es':
        return l10n.spanish;
      case 'en':
        return l10n.english;
      case 'pt':
        return l10n.portuguese;
      case 'fr':
        return l10n.french;
      case 'ru':
        return l10n.russian;
      case 'de':
        return l10n.german;
      case 'it':
        return l10n.italian;
      case 'ko':
        return l10n.korean;
      case 'zh':
        return l10n.chinese;
      case 'ja':
        return l10n.japanese;
      case 'sw':
        return l10n.swahili;
      default:
        return l10n.spanish;
    }
  }

  /// Backup Seed Phrase
  Future<void> _showBackupSeed(
      BuildContext context, SettingsProvider settingsProvider) async {
    if (settingsProvider.pinEnabled) {
      final verified = await _verifyPinDialog(context, settingsProvider);
      if (!verified) return;
    }

    final mnemonic = await settingsProvider.getMnemonic();
    if (mnemonic == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.mnemonicNotFound),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BackupSeedScreen(
            mnemonic: mnemonic,
            isFromSettings: true,
          ),
        ),
      );
    }
  }

  /// Toggle PIN
  Future<void> _togglePin(
      BuildContext context, SettingsProvider settingsProvider, bool enable) async {
    if (enable) {
      final pin = await _showCreatePinDialog(context);
      if (pin != null && pin.length == 4) {
        await settingsProvider.setPin(pin);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.pinActivated),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } else {
      final verified = await _verifyPinDialog(context, settingsProvider);
      if (verified) {
        await settingsProvider.removePin();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.pinDeactivated),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  Future<String?> _showCreatePinDialog(BuildContext context) async {
    final l10n = L10n.of(context)!;

    final firstPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(
        title: l10n.createPin,
        subtitle: l10n.enterPinDigits,
      ),
    );

    if (firstPin == null) return null;

    if (!context.mounted) return null;
    final confirmPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(
        title: l10n.confirmPin,
        subtitle: l10n.enterPinAgain,
      ),
    );

    if (confirmPin == null) return null;

    if (firstPin != confirmPin) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pinMismatch),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }

    return firstPin;
  }

  Future<bool> _verifyPinDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    final l10n = L10n.of(context)!;
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(
        title: l10n.verifyPin,
        subtitle: l10n.enterCurrentPin,
      ),
    );

    if (pin == null) return false;

    if (settingsProvider.verifyPin(pin)) {
      return true;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.incorrectPin),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Recuperar tokens
  void _showRecoverTokensModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const RecoverTokensModal(),
    );
  }

  /// Borrar wallet
  void _showDeleteWalletModal(
      BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DeleteWalletModal(
        onConfirm: () async {
          Navigator.pop(context);
          await _deleteWallet(context, settingsProvider);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _deleteWallet(
      BuildContext context, SettingsProvider settingsProvider) async {
    try {
      final walletProvider = context.read<WalletProvider>();
      await walletProvider.deleteDatabase();
      await settingsProvider.deleteWallet();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.deleteError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Abrir GitHub
  Future<void> _openGitHub() async {
    final url = Uri.parse('https://github.com/Forte11Cuba/elcaju');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.couldNotOpenLink),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
