import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
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
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
          // Botón toggle de unidad (arriba, como cashu.me)
          GestureDetector(
            onTap: () async {
              await walletProvider.cycleUnit();
              await settingsProvider.setActiveUnit(walletProvider.activeUnit);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                toggleLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ojo para ocultar/mostrar balance
          GestureDetector(
            onTap: () {
              setState(() {
                _isBalanceVisible = !_isBalanceVisible;
              });
            },
            child: Icon(
              _isBalanceVisible ? LucideIcons.eye : LucideIcons.eyeOff,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Balance con unidad al lado (como cashu.me: "855 sat")
          StreamBuilder<BigInt>(
            stream: walletProvider.streamBalance(),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? BigInt.zero;
              final formattedBalance = UnitFormatter.formatBalance(balance, activeUnit);

              return Row(
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
    final displayMint = activeMintUrl != null
        ? UnitFormatter.getMintDisplayName(activeMintUrl)
        : 'Sin mint';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MintsScreen()),
          );
        },
        child: Container(
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
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Row(
        children: [
          // Enviar (primero) - acción crítica que mueve dinero
          Expanded(
            child: AnimatedActionButton(
              label: 'Enviar ↗',
              type: ButtonType.criticalAction,
              onTap: _showSendOptions,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          // Recibir (segundo) - acción importante pero segura
          Expanded(
            child: AnimatedActionButton(
              label: '↘ Recibir',
              type: ButtonType.primaryAction,
              onTap: _showReceiveOptions,
            ),
          ),
        ],
      ),
    );
  }

  void _showReceiveOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MethodSelectorModal(
        title: 'Recibir',
        options: [
          _MethodOption(
            icon: LucideIcons.bean,
            label: 'Cashu',
            description: 'Pegar token ecash',
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
            label: 'Lightning',
            description: 'Generar invoice para depositar',
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MethodSelectorModal(
        title: 'Enviar',
        options: [
          _MethodOption(
            icon: LucideIcons.bean,
            label: 'Cashu',
            description: 'Crear token ecash',
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
            label: 'Lightning',
            description: 'Pagar invoice Lightning',
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
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: AnimatedActionButton(
        label: 'Historial',
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
