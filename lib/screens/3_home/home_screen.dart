import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/incoming_data_parser.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/animated_action_button.dart';
import '../../widgets/effects/cashu_confetti.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/settings_provider.dart';
import '../4_receive/receive_screen.dart';
import '../5_send/send_screen.dart';
import '../6_mint/mint_screen.dart';
import '../7_melt/melt_screen.dart';
import '../8_settings/settings_screen.dart';
import '../8_settings/mints_screen.dart';
import '../9_history/history_screen.dart';
import '../10_scanner/scan_screen.dart';

/// Pantalla principal - Home
/// Muestra balance, acciones principales e historial
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado local
  bool _isBalanceVisible = true;

  // Controller para el efecto confeti
  final CashuConfettiController _confettiController = CashuConfettiController();

  @override
  void initState() {
    super.initState();
    // Verificar tokens pendientes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingTokens();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// Verifica y reclama automáticamente tokens pendientes
  Future<void> _checkPendingTokens() async {
    final walletProvider = context.read<WalletProvider>();
    if (!walletProvider.hasPendingTokens) return;

    try {
      final result = await walletProvider.checkPendingTokens();
      final claimed = (result['claimed'] as int?) ?? 0;
      final totalClaimed = result['totalClaimed'] as BigInt? ?? BigInt.zero;
      final unit = (result['unit'] as String?) ?? walletProvider.activeUnit;

      if (claimed > 0 && mounted) {
        // Disparar confetti
        _confettiController.fire();

        // Mostrar snackbar
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pendingTokensClaimed(claimed, totalClaimed.toString(), unit)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking pending tokens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CashuConfetti(
      controller: _confettiController,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Header (settings, nombre, mascota)
                _buildHeader(),

                // Mint Selector (debajo del header)
                _buildMintSelector(),

                // Contenido principal centrado
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Balance (reactivo con StreamBuilder)
                        _buildBalanceSection(),

                        const SizedBox(height: AppDimensions.paddingLarge),

                        // Acciones principales
                        _buildActions(),
                      ],
                    ),
                  ),
                ),

                // Botón de historial (bottom)
                _buildHistoryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings button (izquierda)
          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall + 4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            child: const Icon(
              LucideIcons.settings,
              color: Colors.white,
              size: 32,
            ),
          ),

          // Nombre de la wallet (centro)
          const Text(
            'ElCaju',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // El Caju (derecha) - toca para confeti
          GestureDetector(
            onTap: () => _confettiController.fire(),
            child: Image.asset(
              'assets/img/elcajucubano.png',
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    final walletProvider = context.watch<WalletProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final activeUnit = walletProvider.activeUnit;
    // Toggle button: "BTC" para sat (como cashu.me)
    final toggleLabel = UnitFormatter.getToggleLabel(activeUnit);
    // Balance label: "sat" minúsculas (como cashu.me)
    final unitLabel = UnitFormatter.getUnitLabel(activeUnit);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
        horizontal: AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Botón toggle de unidad con efecto de hundirse
          _UnitToggleButton(
            label: toggleLabel,
            onTap: () async {
              await walletProvider.cycleUnit();
              await settingsProvider.setActiveUnit(walletProvider.activeUnit);
            },
          ),

          const SizedBox(height: 32),

          // Balance tocable para ocultar/mostrar (sin ojito)
          StreamBuilder<BigInt>(
            stream: walletProvider.streamBalance(),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? BigInt.zero;
              final formattedBalance = UnitFormatter.formatBalance(balance, activeUnit);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _isBalanceVisible ? formattedBalance : '••••••',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBalanceVisible ? unitLabel : '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMintSelector() {
    final walletProvider = context.watch<WalletProvider>();
    final activeMintUrl = walletProvider.activeMintUrl;

    // Extraer nombre del mint para mostrar
    final l10n = L10n.of(context)!;
    final displayMint = activeMintUrl != null
        ? UnitFormatter.getMintDisplayName(activeMintUrl)
        : l10n.noMint;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MintsScreen()),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo del mint
            if (activeMintUrl != null)
              FutureBuilder(
                future: walletProvider.fetchMintInfo(activeMintUrl),
                builder: (context, snapshot) {
                  final iconUrl = snapshot.data?.iconUrl;
                  return Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: iconUrl != null
                        ? ClipOval(
                            child: Image.network(
                              iconUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                LucideIcons.landmark,
                                color: AppColors.primaryAction,
                                size: 18,
                              ),
                            ),
                          )
                        : const Icon(
                            LucideIcons.landmark,
                            color: AppColors.primaryAction,
                            size: 18,
                          ),
                  );
                },
              ),
            // Pill del mint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: walletProvider.isInitialized
                          ? AppColors.success
                          : AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    displayMint,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    LucideIcons.chevronDown,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    final l10n = L10n.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          // Enviar (primero) - acción crítica que mueve dinero
          Expanded(
            child: AnimatedActionButton(
              label: l10n.sendAction,
              type: ButtonType.criticalAction,
              onTap: _showSendOptions,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          // Botón scan circular (centro)
          _buildScanButton(),
          const SizedBox(width: AppDimensions.paddingSmall),
          // Recibir (segundo) - acción importante pero segura
          Expanded(
            child: AnimatedActionButton(
              label: l10n.receiveAction,
              type: ButtonType.primaryAction,
              onTap: _showReceiveOptions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.buttonGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAction.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          LucideIcons.scan,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(mode: ScanMode.any),
      ),
    );
  }

  void _showReceiveOptions() {
    final l10n = L10n.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MethodSelectorModal(
        title: l10n.receive,
        options: [
          _MethodOption(
            icon: LucideIcons.bean,
            label: l10n.cashu,
            description: l10n.pasteEcashToken,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceiveScreen()),
              );
            },
          ),
          _MethodOption(
            icon: LucideIcons.zap,
            label: l10n.lightning,
            description: l10n.generateInvoiceToDeposit,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MintScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSendOptions() {
    final l10n = L10n.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MethodSelectorModal(
        title: l10n.send,
        options: [
          _MethodOption(
            icon: LucideIcons.bean,
            label: l10n.cashu,
            description: l10n.createEcashToken,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SendScreen()),
              );
            },
          ),
          _MethodOption(
            icon: LucideIcons.zap,
            label: l10n.lightning,
            description: l10n.payLightningInvoice,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeltScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    final l10n = L10n.of(context)!;
    final walletProvider = context.watch<WalletProvider>();
    final pendingCount = walletProvider.pendingTokenCount;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedActionButton(
            label: l10n.history,
            type: ButtonType.navigation,
            icon: LucideIcons.history,
            showIcon: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          // Badge de tokens pendientes
          if (pendingCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.deepVoidPurple,
                    width: 2,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  pendingCount > 9 ? '9+' : pendingCount.toString(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Modelo para opciones del selector
class _MethodOption {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  _MethodOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });
}

/// Modal selector de método (Lightning / Cashu)
class _MethodSelectorModal extends StatelessWidget {
  final String title;
  final List<_MethodOption> options;

  const _MethodSelectorModal({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
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

          // Título
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),

          // Opciones
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppDimensions.paddingSmall,
              ),
              child: _MethodOptionTile(option: option),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingSmall),
        ],
      ),
    );
  }
}

/// Tile para cada opción del selector
class _MethodOptionTile extends StatelessWidget {
  final _MethodOption option;

  const _MethodOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: option.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.buttonGradient,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Flecha
            Icon(
              LucideIcons.chevronRight,
              color: Colors.white.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón de toggle de unidad con efecto de hundirse
class _UnitToggleButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _UnitToggleButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_UnitToggleButton> createState() => _UnitToggleButtonState();
}

class _UnitToggleButtonState extends State<_UnitToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
