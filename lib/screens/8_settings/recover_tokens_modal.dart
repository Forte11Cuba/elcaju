import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:elcaju/l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_provider.dart';

/// Modal para recuperar tokens usando NUT-13
class RecoverTokensModal extends StatefulWidget {
  const RecoverTokensModal({super.key});

  @override
  State<RecoverTokensModal> createState() => _RecoverTokensModalState();
}

class _RecoverTokensModalState extends State<RecoverTokensModal> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMints());
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
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
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

          int mintsRecovered = 0;
          int mintsWithError = 0;
          final recoveredDetails = <String>[];

          for (final mintEntry in results.entries) {
            final unitBalances = mintEntry.value;
            bool hasError = false;
            bool hasRecovered = false;
            for (final unitEntry in unitBalances.entries) {
              final unit = unitEntry.key;
              final balance = unitEntry.value;
              if (balance < BigInt.zero) {
                hasError = true;
              } else if (balance > BigInt.zero) {
                final formatted = UnitFormatter.formatBalance(balance, unit);
                final label = UnitFormatter.getUnitLabel(unit);
                recoveredDetails.add('$formatted $label');
                hasRecovered = true;
              }
            }

            if (hasError) mintsWithError++;
            if (hasRecovered) mintsRecovered++;
          }

          if (!mounted) return;
          setState(() {
            _isSuccess = true;
            if (recoveredDetails.isNotEmpty) {
              _result = l10n.recoveredTokens(recoveredDetails.join(", "), mintsRecovered);
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
