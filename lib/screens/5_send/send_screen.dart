import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/numpad_widget.dart';
import '../../providers/wallet_provider.dart';
import '../../core/utils/nostr_utils.dart';
import 'share_token_screen.dart';
import 'offline_send_screen.dart';

/// Pantalla para enviar tokens Cashu
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _pubkeyController = TextEditingController();

  String _amountValue = '';
  bool _isProcessing = false;
  String? _errorMessage;
  BigInt _availableBalance = BigInt.zero;
  late String _activeUnit;

  // P2PK
  bool _useP2PK = false;
  String? _pubkeyError;

  @override
  void initState() {
    super.initState();
    _activeUnit = context.read<WalletProvider>().activeUnit;
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final walletProvider = context.read<WalletProvider>();
    final balance = await walletProvider.getBalance();
    if (mounted) {
      setState(() {
        _availableBalance = balance;
      });
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    _pubkeyController.dispose();
    super.dispose();
  }

  /// Obtiene la etiqueta de la unidad para display
  String get _unitLabel => UnitFormatter.getUnitLabel(_activeUnit);

  /// Parsea los dígitos crudos a BigInt (ya son centavos para USD/EUR)
  BigInt get _amount => UnitFormatter.parseRawDigits(_amountValue, _activeUnit);

  bool get _isValidAmount => _amount > BigInt.zero && _amount <= _availableBalance;

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
          title: Text(
            L10n.of(context)!.sendCashu,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            // Botón para modo offline (selección manual de proofs)
            IconButton(
              icon: const Icon(LucideIcons.coins, color: AppColors.primaryAction),
              tooltip: L10n.of(context)!.selectNotesManually,
              onPressed: _goToOfflineMode,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Monto a enviar
                      _buildAmountSection(),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Memo opcional
                      _buildMemoSection(),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // P2PK (bloquear a clave pública)
                      _buildP2PKSection(),

                      const SizedBox(height: AppDimensions.paddingMedium),

                      // Mensaje de error (si hay)
                      if (_errorMessage != null) _buildErrorMessage(),
                    ],
                  ),
                ),
              ),

              // Botón crear token (fijo abajo)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: _buildCreateButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      children: [
        // Display del monto
        _buildAmountDisplay(),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Balance disponible
        _buildBalanceRow(),
        const SizedBox(height: AppDimensions.paddingMedium),

        // Teclado numérico
        NumpadWidget(
          value: _amountValue,
          showMaxButton: true,
          onMaxPressed: _setMaxAmount,
          onChanged: (newValue) {
            setState(() {
              _errorMessage = null;
              _amountValue = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountDisplay() {
    final displayAmount = UnitFormatter.formatRawDigitsForDisplay(_amountValue, _activeUnit);

    return Column(
      children: [
        Text(
          displayAmount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: _isValidAmount || _amountValue.isEmpty
                ? Colors.white
                : AppColors.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _unitLabel,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow() {
    final l10n = L10n.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${l10n.available} ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${UnitFormatter.formatBalance(_availableBalance, _activeUnit)} $_unitLabel',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryAction,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoSection() {
    final l10n = L10n.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.memoOptional,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        GlassCard(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: TextField(
            controller: _memoController,
            maxLines: 2,
            maxLength: 100,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: l10n.memoPlaceholder,
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              counterStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildP2PKSection() {
    final l10n = L10n.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle P2PK
        GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.lock,
                color: _useP2PK ? AppColors.primaryAction : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.p2pkLockToKey,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      l10n.p2pkLockDescription,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useP2PK,
                onChanged: (value) {
                  setState(() {
                    _useP2PK = value;
                    if (!value) {
                      _pubkeyController.clear();
                      _pubkeyError = null;
                    }
                  });
                },
                activeColor: AppColors.primaryAction,
              ),
            ],
          ),
        ),

        // Campo pubkey (visible solo si P2PK está activo)
        if (_useP2PK) ...[
          const SizedBox(height: AppDimensions.paddingSmall),

          GlassCard(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            child: TextField(
              controller: _pubkeyController,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: l10n.p2pkReceiverPubkey,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                errorText: _pubkeyError,
                errorStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.error,
                ),
                prefixIcon: Icon(
                  LucideIcons.key,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 18,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    LucideIcons.clipboard,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  onPressed: _pastePubkey,
                ),
              ),
              onChanged: _validatePubkey,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingSmall),

          // Advertencia experimental
          Row(
            children: [
              Icon(
                LucideIcons.alertTriangle,
                size: 14,
                color: AppColors.warning.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.p2pkExperimental,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.warning.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _validatePubkey(String value) {
    if (value.isEmpty) {
      setState(() => _pubkeyError = null);
      return;
    }

    final isValid = NostrUtils.isValidP2PKPubkey(value);
    setState(() {
      _pubkeyError = isValid ? null : L10n.of(context)!.p2pkInvalidPubkey;
    });
  }

  Future<void> _pastePubkey() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      _pubkeyController.text = clipboardData!.text!;
      _validatePubkey(clipboardData.text!);
    }
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertCircle,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final l10n = L10n.of(context)!;
    // Si P2PK está habilitado, también debe haber una pubkey válida
    final isP2PKValid = !_useP2PK ||
        (_pubkeyController.text.isNotEmpty && _pubkeyError == null);
    final canCreate = _isValidAmount && !_isProcessing && isP2PKValid;
    return PrimaryButton(
      text: _isProcessing ? l10n.creatingToken : l10n.createToken,
      onPressed: canCreate ? _showConfirmation : null,
    );
  }

  void _setMaxAmount() {
    setState(() {
      // El balance ya está en la unidad base (centavos para USD/EUR, sats para SAT)
      _amountValue = _availableBalance.toString();
      _errorMessage = null;
    });
  }

  /// Navegar al modo offline para seleccionar proofs manualmente.
  void _goToOfflineMode() {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = walletProvider.activeMintUrl;

    if (mintUrl == null) {
      setState(() {
        _errorMessage = L10n.of(context)!.noActiveMint;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfflineSendScreen(
          mintUrl: mintUrl,
          unit: _activeUnit,
        ),
      ),
    );
  }

  void _showConfirmation() async {
    // Verificar conectividad antes de mostrar confirmación
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = walletProvider.activeMintUrl;

    if (mintUrl == null) {
      setState(() {
        _errorMessage = L10n.of(context)!.noActiveMint;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final isOnline = await _checkConnectivity(mintUrl);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (!isOnline) {
      // P2PK requiere conexión al mint
      if (_useP2PK) {
        setState(() {
          _errorMessage = L10n.of(context)!.p2pkRequiresConnection;
        });
        return;
      }
      // Offline: ir directo a selección de monedas
      _goToOfflineModeWithMessage();
      return;
    }

    // Online: mostrar modal de confirmación normal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConfirmationModal(
        amount: _amount,
        unit: _activeUnit,
        memo: _memoController.text.isNotEmpty ? _memoController.text : null,
        onConfirm: () {
          Navigator.pop(context);
          _createToken();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  /// Verifica conectividad haciendo petición HTTP real al mint.
  Future<bool> _checkConnectivity(String mintUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$mintUrl/v1/info'),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _createToken() async {
    final l10n = L10n.of(context)!;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      // Crear token real con cdk-flutter
      final memo = _memoController.text.isNotEmpty ? _memoController.text : null;
      final amount = _amount;

      String token;

      // P2PK: bloquear a clave pública si está habilitado
      if (_useP2PK && _pubkeyController.text.isNotEmpty) {
        // Verificar si hay txs P2PK pending (workaround CDK bug)
        final hasPending = await walletProvider.hasPendingOutgoingTransactions();
        if (hasPending) {
          if (!mounted) return;
          setState(() {
            _errorMessage = l10n.p2pkPendingSendWarning;
            _isProcessing = false;
          });
          return;
        }

        // Usar normalizeToCompressedHex para obtener formato SEC1 (66 chars)
        final pubkeyHex = NostrUtils.normalizeToCompressedHex(_pubkeyController.text);
        if (pubkeyHex == null) {
          throw Exception(l10n.p2pkInvalidPubkey);
        }
        token = await walletProvider.sendTokensP2pk(amount, pubkeyHex, memo);
      } else {
        debugPrint('[SendScreen] Sending normal token, amount: $amount');
        token = await walletProvider.sendTokens(amount, memo);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShareTokenScreen(
              token: token,
              amount: amount,
              unit: _activeUnit,
              memo: memo,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[SendScreen] ERROR creating token: $e');
      debugPrint('[SendScreen] Stack trace: $stackTrace');
      final errorStr = e.toString().toLowerCase();

      // Detectar errores de red y redirigir a modo offline
      if (_isNetworkError(errorStr)) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          _goToOfflineModeWithMessage();
        }
        return;
      }

      if (mounted) {
        setState(() {
          if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
            _errorMessage = l10n.insufficientBalance;
          } else {
            _errorMessage = l10n.tokenCreationError(e.toString());
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Detecta si el error es de conexión/red.
  bool _isNetworkError(String errorStr) {
    return errorStr.contains('transport error') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('socket') ||
        errorStr.contains('timeout') ||
        errorStr.contains('unreachable') ||
        errorStr.contains('no route') ||
        errorStr.contains('error sending request');
  }

  /// Navegar al modo offline mostrando mensaje informativo.
  void _goToOfflineModeWithMessage() {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = walletProvider.activeMintUrl;

    if (mintUrl == null) {
      setState(() {
        _errorMessage = L10n.of(context)!.noActiveMint;
      });
      return;
    }

    // Mostrar snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.offlineModeMessage),
        backgroundColor: AppColors.primaryAction,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navegar a modo offline
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OfflineSendScreen(
          mintUrl: mintUrl,
          unit: _activeUnit,
        ),
      ),
    );
  }
}

/// Modal de confirmacion
class _ConfirmationModal extends StatelessWidget {
  final BigInt amount;
  final String unit;
  final String? memo;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ConfirmationModal({
    required this.amount,
    required this.unit,
    this.memo,
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

          // Icono
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryAction.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.send,
              color: AppColors.primaryAction,
              size: 32,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),

          // Titulo
          Text(
            L10n.of(context)!.confirmSend,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Monto
          Text(
            '${UnitFormatter.formatBalance(amount, unit)} ${UnitFormatter.getUnitLabel(unit)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // Memo
          if (memo != null && memo!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              '"$memo"',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],

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
                    child: Center(
                      child: Text(
                        L10n.of(context)!.cancel,
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
                child: PrimaryButton(
                  text: L10n.of(context)!.confirm,
                  onPressed: onConfirm,
                  height: 52,
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
