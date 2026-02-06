import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cdk_flutter/cdk_flutter.dart' hide WalletProvider;
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/effects/cashu_confetti.dart';
import '../../providers/wallet_provider.dart';
import '../4_receive/receive_screen.dart';
import '../5_send/send_screen.dart';
import '../6_mint/mint_screen.dart';
import '../7_melt/melt_screen.dart';
import '../8_settings/settings_screen.dart';
import '../8_settings/mints_screen.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
        horizontal: AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ojo encima del saldo (centrado)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  _isBalanceVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Balance reactivo del mint activo
          StreamBuilder<BigInt>(
            stream: walletProvider.streamBalance(),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? BigInt.zero;
              final balanceInt = balance.toInt();

              return Text(
                _isBalanceVisible ? _formatBalance(balanceInt) : '••••••',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 4),

          // Unidad (siempre sats por ahora)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAction.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'sats',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAction,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMintSelector() {
    final walletProvider = context.watch<WalletProvider>();
    final activeMintUrl = walletProvider.activeMintUrl;

    // Extraer solo el host del URL para mostrar
    String displayMint = 'Sin mint';
    if (activeMintUrl != null) {
      try {
        final uri = Uri.parse(activeMintUrl);
        displayMint = uri.host;
      } catch (_) {
        displayMint = activeMintUrl;
      }
    }

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
          // Enviar (primero) - flecha diagonal arriba derecha
          Expanded(
            child: _ActionButton(label: 'Enviar ↗', onTap: _showSendOptions),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          // Recibir (segundo) - flecha diagonal abajo derecha
          Expanded(
            child: _ActionButton(
              label: '↘ Recibir',
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
      child: SizedBox(
        width: double.infinity,
        child: GlassCard(
          onTap: _showHistoryModal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium + 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.history, color: Colors.white, size: 28),
              SizedBox(width: AppDimensions.paddingSmall),
              Text(
                'Historial',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _HistoryModal(),
    );
  }

  String _formatBalance(int amount) {
    if (amount >= 1000) {
      final formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return formatted;
    }
    return amount.toString();
  }
}

/// Botón de acción para el home
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
          horizontal: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.buttonGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAction.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal del historial de transacciones
class _HistoryModal extends StatelessWidget {
  const _HistoryModal();

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.deepVoidPurple,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          const Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(
              'Historial',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Lista de transacciones
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: walletProvider.getAllTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAction,
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  return _buildEmptyHistory();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return _TransactionTile(transaction: tx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.history,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'Sin transacciones aún',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Recibe tokens Cashu para empezar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile para mostrar una transacción
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.direction == TransactionDirection.incoming;
    final amount = transaction.amount.toInt();
    final fee = transaction.fee.toInt();

    // Convertir timestamp (BigInt unix) a DateTime
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      transaction.timestamp.toInt() * 1000,
    );

    // Formatear fecha
    final dateStr = _formatDate(timestamp);

    // Estado (pending o settled)
    final isPending = transaction.status == TransactionStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icono de dirección
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isIncoming ? AppColors.success : AppColors.primaryAction)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncoming ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: isIncoming ? AppColors.success : AppColors.primaryAction,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),

          // Info de la transacción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isIncoming ? 'Recibido' : 'Enviado',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pendiente',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
                if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.memo!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Monto
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncoming ? '+' : '-'}$amount',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncoming ? AppColors.success : AppColors.primaryAction,
                ),
              ),
              if (fee > 0)
                Text(
                  'fee: $fee',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Hace ${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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
