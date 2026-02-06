import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

/// Pantalla para gestionar mints conectados
class MintsScreen extends StatefulWidget {
  const MintsScreen({super.key});

  @override
  State<MintsScreen> createState() => _MintsScreenState();
}

class _MintsScreenState extends State<MintsScreen> {
  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            'Mints conectados',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              final mintUrls = walletProvider.mintUrls;

              return Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lista de mints
                    Expanded(
                      child: mintUrls.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: mintUrls.length,
                              itemBuilder: (context, index) {
                                final mintUrl = mintUrls[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppDimensions.paddingMedium,
                                  ),
                                  child: _buildMintCard(
                                    mintUrl,
                                    walletProvider,
                                  ),
                                );
                              },
                            ),
                    ),

                    // Botón agregar mint
                    _buildAddMintButton(walletProvider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.server,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay mints conectados',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un mint para comenzar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMintCard(String mintUrl, WalletProvider walletProvider) {
    final isActive = walletProvider.activeMintUrl == mintUrl;
    final units = walletProvider.getUnitsForMint(mintUrl);

    return FutureBuilder<Map<String, BigInt>>(
      future: walletProvider.getBalancesForMint(mintUrl),
      builder: (context, balanceSnapshot) {
        final balances = balanceSnapshot.data ?? {};

        return GlassCard(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: URL + estado + refresh
              Row(
                children: [
                  // Icono estado conexión (verde si es el activo)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // URL del mint (display name)
                  Expanded(
                    child: Text(
                      UnitFormatter.getMintDisplayName(mintUrl),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Botón refresh
                  GestureDetector(
                    onTap: () => _refreshMint(mintUrl, walletProvider),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.refreshCw,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Badge activo
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Activo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAction,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              // URL completa (más pequeña)
              Text(
                mintUrl,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.paddingSmall),

              // Balances por unidad
              if (balanceSnapshot.connectionState == ConnectionState.waiting)
                Row(
                  children: [
                    Text(
                      'Balance:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                _buildBalancesList(units, balances),

              const SizedBox(height: AppDimensions.paddingMedium),

              // Acciones
              Row(
                children: [
                  // Hacer activo (si no lo es)
                  if (!isActive)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _setActiveMint(mintUrl, walletProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.star,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Usar este mint',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (!isActive) const SizedBox(width: 8),

                  // Eliminar
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showDeleteDialog(mintUrl, balances, walletProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la lista de balances por unidad.
  Widget _buildBalancesList(List<String> units, Map<String, BigInt> balances) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balances:',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        ...units.map((unit) {
          final balance = balances[unit] ?? BigInt.zero;
          final formattedBalance = UnitFormatter.formatBalance(balance, unit);
          final unitLabel = UnitFormatter.getUnitLabel(unit);

          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: balance > BigInt.zero
                        ? AppColors.success
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$formattedBalance $unitLabel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: balance > BigInt.zero ? FontWeight.w600 : FontWeight.normal,
                    color: balance > BigInt.zero
                        ? Colors.white
                        : AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Refresca la información del mint (detecta nuevas unidades).
  Future<void> _refreshMint(String mintUrl, WalletProvider walletProvider) async {
    try {
      final units = await walletProvider.refreshMint(mintUrl);

      if (mounted) {
        setState(() {}); // Rebuild para actualizar UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unidades detectadas: ${units.join(", ")}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildAddMintButton(WalletProvider walletProvider) {
    return PrimaryButton(
      text: 'Agregar mint',
      icon: LucideIcons.plus,
      onPressed: () => _showAddMintDialog(walletProvider),
    );
  }

  Future<void> _setActiveMint(String mintUrl, WalletProvider walletProvider) async {
    try {
      await walletProvider.setActiveMint(mintUrl);

      if (mounted) {
        setState(() {}); // Rebuild para actualizar UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mint activo actualizado'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(String mintUrl, Map<String, BigInt> balances, WalletProvider walletProvider) {
    // Verificar si hay balance en alguna unidad
    final hasBalance = balances.values.any((b) => b > BigInt.zero);

    // Calcular balance total para mostrar (simplificado)
    final balanceStrings = balances.entries
        .where((e) => e.value > BigInt.zero)
        .map((e) => '${UnitFormatter.formatBalance(e.value, e.key)} ${UnitFormatter.getUnitLabel(e.key)}')
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteMintModal(
        mintUrl: mintUrl,
        hasBalance: hasBalance,
        balanceDescription: balanceStrings.isEmpty ? '' : balanceStrings.join(', '),
        onConfirm: () async {
          Navigator.pop(context);
          await _deleteMint(mintUrl, walletProvider);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _deleteMint(String mintUrl, WalletProvider walletProvider) async {
    try {
      await walletProvider.removeMint(mintUrl);

      if (mounted) {
        setState(() {}); // Rebuild para actualizar UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mint eliminado'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddMintDialog(WalletProvider walletProvider) {
    showDialog(
      context: context,
      builder: (context) => _AddMintDialog(
        walletProvider: walletProvider,
        onSuccess: () {
          // Forzar rebuild para mostrar el nuevo mint
          setState(() {});
        },
      ),
    );
  }
}

/// Modal para confirmar eliminación de mint
class _DeleteMintModal extends StatelessWidget {
  final String mintUrl;
  final bool hasBalance;
  final String balanceDescription;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _DeleteMintModal({
    required this.mintUrl,
    required this.hasBalance,
    required this.balanceDescription,
    required this.onConfirm,
    required this.onCancel,
  });

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
          const Text(
            '¿Eliminar mint?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // URL del mint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              mintUrl,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Advertencia según balance
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasBalance
                  ? AppColors.secondaryAction.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasBalance ? LucideIcons.alertCircle : LucideIcons.info,
                  color: hasBalance ? AppColors.secondaryAction : AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasBalance
                        ? 'Este mint tiene $balanceDescription. Puedes recuperarlos después agregando el mint de nuevo.'
                        : 'Perderás acceso a este mint',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: hasBalance
                          ? AppColors.secondaryAction
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
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
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
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
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
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
            ],
          ),

          const SizedBox(height: AppDimensions.paddingSmall),
        ],
      ),
    );
  }
}

/// Diálogo para agregar nuevo mint
class _AddMintDialog extends StatefulWidget {
  final WalletProvider walletProvider;
  final VoidCallback onSuccess;

  const _AddMintDialog({
    required this.walletProvider,
    required this.onSuccess,
  });

  @override
  State<_AddMintDialog> createState() => _AddMintDialogState();
}

class _AddMintDialogState extends State<_AddMintDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isValid = false;
  bool _isAdding = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.deepVoidPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Agregar mint',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'URL del mint:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            enabled: !_isAdding,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'https://mint.example.com',
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
              errorText: _errorMessage,
              errorStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
            onChanged: _validateUrl,
          ),
          if (_isAdding) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryAction,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Conectando al mint...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: _isAdding
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: (_isValid && !_isAdding) ? _addMint : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAction,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primaryAction.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Agregar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _validateUrl(String value) {
    setState(() {
      _errorMessage = null;
    });

    if (value.isEmpty) {
      setState(() {
        _isValid = false;
      });
      return;
    }

    // Validación básica de URL
    final isValidBasic =
        value.startsWith('http://') || value.startsWith('https://');

    if (!isValidBasic) {
      setState(() {
        _isValid = false;
        _errorMessage = 'La URL debe comenzar con https://';
      });
      return;
    }

    setState(() {
      _isValid = true;
    });
  }

  Future<void> _addMint() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isAdding = true;
      _errorMessage = null;
    });

    try {
      // Intentar agregar el mint (cdk_flutter validará la conexión)
      await widget.walletProvider.addMint(url);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mint agregado correctamente'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAdding = false;
          _errorMessage = 'No se pudo conectar al mint';
        });
      }
    }
  }
}
