import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/glass_card.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/p2pk_provider.dart';
import '../3_home/home_screen.dart';

/// Pantalla de restauración de wallet
class RestoreWalletScreen extends StatefulWidget {
  const RestoreWalletScreen({super.key});

  @override
  State<RestoreWalletScreen> createState() => _RestoreWalletScreenState();
}

class _RestoreWalletScreenState extends State<RestoreWalletScreen> {
  final TextEditingController _seedController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isRestoring = false;
  String? _errorMessage;

  int get _wordCount {
    final text = _seedController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  bool get _isValidWordCount => _wordCount == 12 || _wordCount == 24;

  @override
  void initState() {
    super.initState();
    _seedController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _seedController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _restoreWallet() async {
    if (!_isValidWordCount) return;

    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final mnemonic = _seedController.text.trim().toLowerCase();
      final walletProvider = context.read<WalletProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final p2pkProvider = context.read<P2PKProvider>();

      // Guardar mnemonic de forma segura
      await settingsProvider.saveMnemonic(mnemonic);

      // Inicializar wallet (esto valida el mnemonic internamente)
      // Si el mnemonic es inválido, cdk_flutter lanzará una excepción
      await walletProvider.initialize(mnemonic);

      // Inicializar P2PK (derivar clave principal del mnemonic)
      try {
        await p2pkProvider.initialize(mnemonic);
      } catch (e) {
        debugPrint('[RestoreWalletScreen] Error initializing P2PK (non-fatal): $e');
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Revertir el guardado del mnemonic si falló la inicialización
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.deleteWallet();

      final l10n = L10n.of(context)!;
      setState(() {
        _errorMessage = l10n.restoreError(e.toString());
        _isRestoring = false;
      });
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
            l10n.restoreTitle,
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
                  l10n.enterSeedPhrase,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSmall),

                Text(
                  l10n.enterSeedDescription,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: TextField(
                      controller: _seedController,
                      focusNode: _focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.seedPlaceholder,
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                Row(
                  children: [
                    Icon(
                      _isValidWordCount
                          ? LucideIcons.checkCircle
                          : LucideIcons.info,
                      size: 18,
                      color: _isValidWordCount
                          ? AppColors.success
                          : AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.wordCount(_wordCount),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: _isValidWordCount
                            ? AppColors.success
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    if (_wordCount > 0 && !_isValidWordCount) ...[
                      const SizedBox(width: 8),
                      Text(
                        l10n.needWords,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.paddingMedium),
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

                const SizedBox(height: AppDimensions.paddingLarge),

                PrimaryButton(
                  text: l10n.restoreWallet,
                  icon: LucideIcons.rotateCcw,
                  isLoading: _isRestoring,
                  onPressed: _isValidWordCount && !_isRestoring
                      ? _restoreWallet
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
