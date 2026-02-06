import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:cdk_flutter/cdk_flutter.dart' show MintInfo;
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import 'mint_detail_screen.dart';

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
              return Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lista de mints ordenados por balance
                    Expanded(
                      child: FutureBuilder<List<String>>(
                        future: walletProvider.getSortedMintUrls(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryAction,
                              ),
                            );
                          }

                          final mintUrls = snapshot.data ?? walletProvider.mintUrls;

                          if (mintUrls.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.builder(
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
    final isCubaBitcoin = mintUrl == WalletProvider.cubaBitcoinMint;

    return FutureBuilder<Map<String, BigInt>>(
      future: walletProvider.getBalancesForMint(mintUrl),
      builder: (context, balanceSnapshot) {
        final balances = balanceSnapshot.data ?? {};

        return FutureBuilder<MintInfo?>(
          future: walletProvider.fetchMintInfo(mintUrl),
          builder: (context, infoSnapshot) {
            final mintInfo = infoSnapshot.data;
            final mintName = mintInfo?.name ?? UnitFormatter.getMintDisplayName(mintUrl);
            final iconUrl = mintInfo?.iconUrl;

            return GestureDetector(
              onTap: () => _openMintDetails(
                mintUrl,
                walletProvider,
                mintInfo,
                balances,
                isActive,
                isCubaBitcoin,
              ),
              child: GlassCard(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    // Logo del mint
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAction.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: iconUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  LucideIcons.landmark,
                                  color: AppColors.primaryAction,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Icon(
                              LucideIcons.landmark,
                              color: AppColors.primaryAction,
                              size: 24,
                            ),
                    ),

                    const SizedBox(width: 12),

                    // Info del mint
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre + badge activo
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mintName,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // URL
                          Text(
                            mintUrl,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Balance badge
                          if (balanceSnapshot.connectionState == ConnectionState.waiting)
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textSecondary,
                              ),
                            )
                          else
                            _buildBalanceBadges(units, balances),
                        ],
                      ),
                    ),

                    // Chevron
                    Icon(
                      LucideIcons.chevronRight,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Badges de balance compactos (estilo cashu.me)
  Widget _buildBalanceBadges(List<String> units, Map<String, BigInt> balances) {
    final nonZeroBalances = balances.entries
        .where((e) => e.value > BigInt.zero)
        .toList();

    if (nonZeroBalances.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '0 ${units.isNotEmpty ? units.first : "sat"}',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: nonZeroBalances.map((entry) {
        final unit = entry.key;
        final balance = entry.value;
        final formatted = UnitFormatter.formatBalance(balance, unit);
        final label = UnitFormatter.getUnitLabel(unit);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryAction.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$formatted $label',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryAction,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Abre la pantalla de detalles del mint
  void _openMintDetails(
    String mintUrl,
    WalletProvider walletProvider,
    MintInfo? mintInfo,
    Map<String, BigInt> balances,
    bool isActive,
    bool isCubaBitcoin,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MintDetailScreen(
          mintUrl: mintUrl,
          mintInfo: mintInfo,
          isActive: isActive,
          balances: balances,
          onSetActive: isActive
              ? null
              : () => _setActiveMint(mintUrl, walletProvider),
          onDelete: isCubaBitcoin
              ? null
              : () => _deleteMint(mintUrl, walletProvider),
        ),
      ),
    );
  }

  /// Elimina un mint (llamado desde pantalla de detalles)
  Future<void> _deleteMint(String mintUrl, WalletProvider walletProvider) async {
    try {
      await walletProvider.removeMint(mintUrl);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mint eliminado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
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
