import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../2_onboarding/backup_seed_screen.dart';
import 'mints_screen.dart';

/// Pantalla de configuración
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                      icon: LucideIcons.key,
                      title: l10n.backupSeedPhrase,
                      subtitle: l10n.viewRecoveryWords,
                      onTap: () => _showBackupSeed(context, settingsProvider),
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
                        activeColor: AppColors.primaryAction,
                      ),
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.refreshCw,
                      title: l10n.recoverTokens,
                      subtitle: l10n.scanMintsWithSeed,
                      onTap: () => _showRecoverTokensDialog(context, settingsProvider),
                    ),

                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sección IDIOMA
                    _buildSectionHeader(l10n.appearanceSection),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    _buildSettingTile(
                      icon: LucideIcons.globe,
                      title: l10n.language,
                      subtitle: _getLanguageName(settingsProvider.locale),
                      onTap: () => _showLanguageSelector(context, settingsProvider),
                    ),

                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Sección INFORMACIÓN
                    _buildSectionHeader(l10n.informationSection),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    _buildInfoTile(
                      icon: LucideIcons.tag,
                      title: l10n.version,
                      subtitle: '0.0.1',
                    ),
                    _buildSettingTile(
                      icon: LucideIcons.info,
                      title: l10n.about,
                      onTap: () => _showAboutDialog(context),
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
      onTap: () => _showDeleteWalletDialog(context, settingsProvider),
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
  // FUNCIONALIDADES
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
      default:
        return l10n.spanish;
    }
  }

  /// 1. Backup Seed Phrase
  Future<void> _showBackupSeed(
      BuildContext context, SettingsProvider settingsProvider) async {
    // Primero verificar PIN si está activado
    if (settingsProvider.pinEnabled) {
      final verified = await _verifyPinDialog(context, settingsProvider);
      if (!verified) return;
    }

    // Obtener mnemonic
    final mnemonic = await settingsProvider.getMnemonic();
    if (mnemonic == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.mnemonicNotFound),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Navegar a BackupSeedScreen
    if (mounted) {
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

  /// 2. Toggle PIN
  Future<void> _togglePin(
      BuildContext context, SettingsProvider settingsProvider, bool enable) async {
    if (enable) {
      // Activar PIN - mostrar diálogo para crear
      final pin = await _showCreatePinDialog(context);
      if (pin != null && pin.length == 4) {
        await settingsProvider.setPin(pin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.pinActivated),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } else {
      // Desactivar PIN - verificar primero
      final verified = await _verifyPinDialog(context, settingsProvider);
      if (verified) {
        await settingsProvider.removePin();
        if (mounted) {
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
    String? firstPin;

    // Primer ingreso
    firstPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PinDialog(
        title: l10n.createPin,
        subtitle: l10n.enterPinDigits,
      ),
    );

    if (firstPin == null) return null;

    // Confirmar PIN
    final confirmPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PinDialog(
        title: l10n.confirmPin,
        subtitle: l10n.enterPinAgain,
      ),
    );

    if (confirmPin == null) return null;

    if (firstPin != confirmPin) {
      if (mounted) {
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
      builder: (context) => _PinDialog(
        title: l10n.verifyPin,
        subtitle: l10n.enterCurrentPin,
      ),
    );

    if (pin == null) return false;

    if (settingsProvider.verifyPin(pin)) {
      return true;
    } else {
      if (mounted) {
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

  /// 3. Selector de idioma
  void _showLanguageSelector(
      BuildContext context, SettingsProvider settingsProvider) {
    final l10n = L10n.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.deepVoidPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.selectLanguage,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildLanguageOption(
              context,
              settingsProvider,
              'es',
              l10n.spanish,
              '🇪🇸',
            ),
            _buildLanguageOption(
              context,
              settingsProvider,
              'en',
              l10n.english,
              '🇬🇧',
            ),
            _buildLanguageOption(
              context,
              settingsProvider,
              'pt',
              l10n.portuguese,
              '🇵🇹',
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    SettingsProvider settingsProvider,
    String locale,
    String name,
    String flag,
  ) {
    final isSelected = settingsProvider.locale == locale;

    return GestureDetector(
      onTap: () async {
        await settingsProvider.setLocale(locale);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.languageChanged(name)),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAction.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAction.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
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
            if (isSelected)
              Icon(
                LucideIcons.check,
                color: AppColors.primaryAction,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// 4. Acerca de
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepVoidPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/img/elcajucubano.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'El Caju',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v0.0.1',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              L10n.of(context)!.aboutTagline,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              L10n.of(context)!.aboutDescription,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.bitcoin,
                    color: AppColors.secondaryAction,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cuba Bitcoin',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryAction,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              L10n.of(context)!.close,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Abrir GitHub
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

  /// 6. Recuperar tokens
  void _showRecoverTokensDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RecoverTokensModal(
        settingsProvider: settingsProvider,
      ),
    );
  }

  /// 7. Borrar wallet
  void _showDeleteWalletDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DeleteWalletModal(
        settingsProvider: settingsProvider,
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
      // Borrar datos del wallet
      final walletProvider = context.read<WalletProvider>();
      await walletProvider.deleteDatabase();
      await settingsProvider.deleteWallet();

      if (mounted) {
        // Navegar a welcome screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.deleteError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Diálogo para ingresar PIN
class _PinDialog extends StatefulWidget {
  final String title;
  final String subtitle;

  const _PinDialog({
    required this.title,
    required this.subtitle,
  });

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final List<String> _pin = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.deepVoidPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Indicadores de PIN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? AppColors.primaryAction
                      : Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: filled
                        ? AppColors.primaryAction
                        : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // Teclado numérico
          _buildNumPad(),
        ],
      ),
    );
  }

  Widget _buildNumPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3'].map((n) => _buildNumKey(n)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6'].map((n) => _buildNumKey(n)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9'].map((n) => _buildNumKey(n)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Cancelar
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  LucideIcons.x,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
            _buildNumKey('0'),
            // Borrar
            GestureDetector(
              onTap: _deleteDigit,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  LucideIcons.delete,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumKey(String number) {
    return GestureDetector(
      onTap: () => _addDigit(number),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(digit);
      });

      if (_pin.length == 4) {
        // PIN completo, cerrar con resultado
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pop(context, _pin.join());
        });
      }
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }
}

/// Modal para confirmar borrado de wallet
class _DeleteWalletModal extends StatefulWidget {
  final SettingsProvider settingsProvider;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteWalletModal({
    required this.settingsProvider,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_DeleteWalletModal> createState() => _DeleteWalletModalState();
}

class _DeleteWalletModalState extends State<_DeleteWalletModal> {
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.deepVoidPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

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
                  child: GestureDetector(
                    onTap: widget.onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: GestureDetector(
                    onTap: _canDelete ? widget.onConfirm : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _canDelete
                            ? AppColors.error
                            : AppColors.error.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          l10n.deleteWallet,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _canDelete
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingSmall),
          ],
        ),
      ),
    );
  }
}

/// Modal para recuperar tokens usando NUT-13
class _RecoverTokensModal extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const _RecoverTokensModal({
    required this.settingsProvider,
  });

  @override
  State<_RecoverTokensModal> createState() => _RecoverTokensModalState();
}

class _RecoverTokensModalState extends State<_RecoverTokensModal> {
  final TextEditingController _mnemonicController = TextEditingController();
  bool _useCurrentMnemonic = true;
  bool _scanAllMints = true;
  String? _selectedMintUrl;
  List<String> _availableMints = [];
  bool _isLoading = false;
  bool _isLoadingMints = true;
  String? _result;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadMints();
  }

  Future<void> _loadMints() async {
    final walletProvider = context.read<WalletProvider>();
    if (mounted) {
      setState(() {
        _availableMints = walletProvider.mintUrls;
        _isLoadingMints = false;
        if (_availableMints.isNotEmpty) {
          _selectedMintUrl = _availableMints.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.deepVoidPurple,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icono
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryAction.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.refreshCw,
                  color: AppColors.primaryAction,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),

              // Título
              Text(
                L10n.of(context)!.recoverTokensTitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),

              // Descripción
              Text(
                L10n.of(context)!.recoverTokensDescription,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingLarge),

              // Opciones de mnemonic
              _buildMnemonicOptions(),

              const SizedBox(height: AppDimensions.paddingMedium),

              // Selector de mint (solo si usa mnemonic actual)
              if (_useCurrentMnemonic) _buildMintSelector(),

              // Input para mnemonic personalizado
              if (!_useCurrentMnemonic) _buildMnemonicInput(),

              // Resultado
              if (_result != null) _buildResult(),

              const SizedBox(height: AppDimensions.paddingMedium),

              // Botón de acción
              _buildActionButton(),

              const SizedBox(height: AppDimensions.paddingSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMnemonicOptions() {
    final l10n = L10n.of(context)!;
    return Column(
      children: [
        // Opción: Usar mnemonic actual
        GestureDetector(
          onTap: () => setState(() => _useCurrentMnemonic = true),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _useCurrentMnemonic
                  ? AppColors.primaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _useCurrentMnemonic
                    ? AppColors.primaryAction.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _useCurrentMnemonic
                      ? LucideIcons.checkCircle
                      : LucideIcons.circle,
                  color: _useCurrentMnemonic
                      ? AppColors.primaryAction
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.useCurrentSeedPhrase,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.scanWithSavedWords,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Opción: Usar otro mnemonic
        GestureDetector(
          onTap: () => setState(() => _useCurrentMnemonic = false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: !_useCurrentMnemonic
                  ? AppColors.primaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !_useCurrentMnemonic
                    ? AppColors.primaryAction.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  !_useCurrentMnemonic
                      ? LucideIcons.checkCircle
                      : LucideIcons.circle,
                  color: !_useCurrentMnemonic
                      ? AppColors.primaryAction
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.useOtherSeedPhrase,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.recoverFromOtherWords,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMintSelector() {
    final l10n = L10n.of(context)!;
    if (_isLoadingMints) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.primaryAction,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.mintsToScan,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        // Opción: Escanear todos
        GestureDetector(
          onTap: () => setState(() => _scanAllMints = true),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _scanAllMints
                  ? AppColors.primaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _scanAllMints
                    ? AppColors.primaryAction.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _scanAllMints ? LucideIcons.checkCircle : LucideIcons.circle,
                  color: _scanAllMints
                      ? AppColors.primaryAction
                      : AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.allMints(_availableMints.length),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: _scanAllMints ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Opción: Mint específico
        GestureDetector(
          onTap: () => setState(() => _scanAllMints = false),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: !_scanAllMints
                  ? AppColors.primaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: !_scanAllMints
                    ? AppColors.primaryAction.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  !_scanAllMints ? LucideIcons.checkCircle : LucideIcons.circle,
                  color: !_scanAllMints
                      ? AppColors.primaryAction
                      : AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.specificMint,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dropdown de mints (solo si selecciona específico)
        if (!_scanAllMints && _availableMints.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedMintUrl,
                isExpanded: true,
                dropdownColor: AppColors.deepVoidPurple,
                underline: const SizedBox(),
                icon: Icon(
                  LucideIcons.chevronDown,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                items: _availableMints.map((url) {
                  final host = Uri.parse(url).host;
                  return DropdownMenuItem(
                    value: url,
                    child: Text(
                      host,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMintUrl = value);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMnemonicInput() {
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.paddingMedium),
      child: TextField(
        controller: _mnemonicController,
        maxLines: 3,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: L10n.of(context)!.enterMnemonicWords,
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isSuccess
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSuccess
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle,
            color: _isSuccess ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _result!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _isSuccess ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _startRecover,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: _isLoading
                ? null
                : const LinearGradient(
                    colors: [AppColors.primaryAction, Color(0xFFFF9100)],
                  ),
            color: _isLoading ? Colors.grey : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    L10n.of(context)!.scanMints,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _startRecover() async {
    if (!mounted) return;
    final l10n = L10n.of(context)!;
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      if (_useCurrentMnemonic) {
        // Usar mnemonic actual
        if (_scanAllMints) {
          // Escanear todos los mints (retorna Map<String, Map<String, BigInt>>)
          final results = await walletProvider.restoreAllMints();

          BigInt totalRecovered = BigInt.zero;
          int mintsScanned = 0;
          int mintsWithError = 0;
          final recoveredDetails = <String>[];

          for (final mintEntry in results.entries) {
            final unitBalances = mintEntry.value;
            bool hasError = false;
            BigInt mintTotal = BigInt.zero;

            for (final unitEntry in unitBalances.entries) {
              final unit = unitEntry.key;
              final balance = unitEntry.value;
              if (balance < BigInt.zero) {
                hasError = true;
              } else if (balance > BigInt.zero) {
                mintTotal += balance;
                final formatted = UnitFormatter.formatBalance(balance, unit);
                final label = UnitFormatter.getUnitLabel(unit);
                recoveredDetails.add('$formatted $label');
              }
            }

            if (hasError) {
              mintsWithError++;
            } else {
              mintsScanned++;
              totalRecovered += mintTotal;
            }
          }

          if (!mounted) return;
          setState(() {
            _isSuccess = true;
            if (recoveredDetails.isNotEmpty) {
              _result = l10n.recoveredTokens(recoveredDetails.join(", "), mintsScanned);
            } else {
              _result = l10n.scanCompleteNoTokens;
            }
            if (mintsWithError > 0) {
              _result = '$_result ${l10n.mintsWithError(mintsWithError)}';
            }
          });
        } else {
          // Escanear mint específico (retorna Map<String, BigInt>)
          if (_selectedMintUrl == null) {
            if (!mounted) return;
            setState(() {
              _isSuccess = false;
              _result = l10n.selectMintToScan;
            });
            return;
          }

          final unitBalances = await walletProvider.restoreFromMint(_selectedMintUrl!);
          final mintHost = UnitFormatter.getMintDisplayName(_selectedMintUrl!);

          final recoveredDetails = <String>[];
          for (final entry in unitBalances.entries) {
            final unit = entry.key;
            final balance = entry.value;
            if (balance > BigInt.zero) {
              final formatted = UnitFormatter.formatBalance(balance, unit);
              final label = UnitFormatter.getUnitLabel(unit);
              recoveredDetails.add('$formatted $label');
            }
          }

          if (!mounted) return;
          setState(() {
            _isSuccess = true;
            if (recoveredDetails.isNotEmpty) {
              _result = l10n.recoveredFromMint(recoveredDetails.join(", "), mintHost);
            } else {
              _result = l10n.noTokensFoundInMint(mintHost);
            }
          });
        }
      } else {
        // Usar otro mnemonic
        final mnemonic = _mnemonicController.text.trim().toLowerCase();
        final words = mnemonic.split(RegExp(r'\s+'));

        if (words.length != 12 && words.length != 24) {
          if (!mounted) return;
          setState(() {
            _isSuccess = false;
            _result = l10n.mnemonicMustHaveWords;
          });
          return;
        }

        // Obtener lista de mints actuales para escanear
        final mintUrls = walletProvider.mintUrls;

        if (mintUrls.isEmpty) {
          if (!mounted) return;
          setState(() {
            _isSuccess = false;
            _result = l10n.noConnectedMintsToScan;
          });
          return;
        }

        final recovered = await walletProvider.restoreWithMnemonic(
          mnemonic,
          mintUrls,
        );

        if (!mounted) return;
        setState(() {
          _isSuccess = true;
          if (recovered > BigInt.zero) {
            // Usamos la unidad activa como aproximación para el formato
            final activeUnit = walletProvider.activeUnit;
            final formatted = UnitFormatter.formatBalance(recovered, activeUnit);
            final label = UnitFormatter.getUnitLabel(activeUnit);
            _result = l10n.recoveredAndTransferred(formatted, label);
          } else {
            _result = l10n.noTokensForMnemonic;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSuccess = false;
        _result = '${l10n.error}: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
