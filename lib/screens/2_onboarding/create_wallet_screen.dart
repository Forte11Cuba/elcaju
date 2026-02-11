import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/glass_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/p2pk_provider.dart';
import 'backup_seed_screen.dart';
import '../3_home/home_screen.dart';

/// Pantalla de creación de wallet
class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  bool _isCreating = false;
  bool _walletCreated = false;
  String? _mnemonic;
  String? _errorMessage;

  Future<void> _createWallet() async {
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final p2pkProvider = context.read<P2PKProvider>();

      // Generar mnemonic real (12 palabras BIP39)
      _mnemonic = walletProvider.generateNewMnemonic();

      // Guardar mnemonic de forma segura
      await settingsProvider.saveMnemonic(_mnemonic!);

      // Inicializar wallet con el mnemonic
      await walletProvider.initialize(_mnemonic!);

      // Inicializar P2PK (derivar clave principal del mnemonic)
      try {
        await p2pkProvider.initialize(_mnemonic!);
      } catch (e) {
        debugPrint('[CreateWalletScreen] Error initializing P2PK (non-fatal): $e');
      }

      setState(() {
        _isCreating = false;
        _walletCreated = true;
      });
    } catch (e) {
      setState(() {
        _isCreating = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _goToBackup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BackupSeedScreen(mnemonic: _mnemonic!),
      ),
    ).then((_) {
      _goToHome();
    });
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
            l10n.createWalletTitle,
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
            child: _walletCreated
                ? _buildBackupOptions(l10n)
                : _buildCreateView(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateView(L10n l10n) {
    return Column(
      children: [
        // Contenido principal centrado
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAction.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCreating ? LucideIcons.hourglass : LucideIcons.wallet,
                    size: 60,
                    color: AppColors.secondaryAction,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                Text(
                  _isCreating ? l10n.creatingWallet : l10n.createWalletTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                Text(
                  _isCreating ? l10n.generatingSeed : l10n.createWalletDescription,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Mensaje de error si existe
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.paddingLarge),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.alertCircle,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Spinner cuando está creando (integrado en el contenido centrado)
                if (_isCreating) ...[
                  const SizedBox(height: AppDimensions.paddingXLarge),
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryAction),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Botón solo cuando no está creando
        if (!_isCreating) ...[
          PrimaryButton(
            text: l10n.generateWallet,
            icon: LucideIcons.sparkles,
            onPressed: _createWallet,
          ),
          const SizedBox(height: AppDimensions.paddingXLarge),
        ],
      ],
    );
  }

  Widget _buildBackupOptions(L10n l10n) {
    return Column(
      children: [
        const Spacer(),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.checkCircle,
            size: 60,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),

        Text(
          l10n.walletCreated,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),

        Text(
          l10n.walletCreatedDescription,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.paddingLarge),

        GlassCard(
          child: Row(
            children: [
              const Icon(
                LucideIcons.alertTriangle,
                color: AppColors.warning,
                size: 32,
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(
                child: Text(
                  l10n.backupWarning,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        PrimaryButton(
          text: l10n.backupNow,
          icon: LucideIcons.shield,
          onPressed: _goToBackup,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),

        SecondaryButton(
          text: l10n.backupLater,
          onPressed: _goToHome,
        ),

        const SizedBox(height: AppDimensions.paddingXLarge),
      ],
    );
  }
}
