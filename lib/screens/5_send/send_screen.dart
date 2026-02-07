import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/wallet_provider.dart';
import 'share_token_screen.dart';
import 'offline_send_screen.dart';

/// Pantalla para enviar tokens Cashu
class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;
  BigInt _availableBalance = BigInt.zero;
  late String _activeUnit;

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
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// Obtiene la etiqueta de la unidad para display
  String get _unitLabel => UnitFormatter.getUnitLabel(_activeUnit);

  /// Parsea el input del usuario a BigInt según la unidad
  BigInt get _amount => UnitFormatter.parseUserInput(_amountController.text, _activeUnit);

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
          title: const Text(
            'Enviar Cashu',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            // Botón para modo offline (selección manual de proofs)
            IconButton(
              icon: const Icon(LucideIcons.coins, color: AppColors.primaryAction),
              tooltip: 'Seleccionar notas manualmente',
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto a enviar:',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),

        // Input de monto
        GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {
                    _errorMessage = null;
                  }),
                ),
              ),
              Text(
                _unitLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.paddingSmall),

        // Balance disponible
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Disponible:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            GestureDetector(
              onTap: _setMaxAmount,
              child: Row(
                children: [
                  Text(
                    '${UnitFormatter.formatBalance(_availableBalance, _activeUnit)} $_unitLabel',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAction,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(Max)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.primaryAction.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Memo (opcional):',
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
              hintText: 'Ej: Para el cafe',
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
    return PrimaryButton(
      text: _isProcessing ? 'Creando token...' : 'Crear token',
      onPressed: _isValidAmount && !_isProcessing ? _showConfirmation : null,
    );
  }

  void _setMaxAmount() {
    // Formatear el balance para el input (sin separadores de miles)
    _amountController.text = UnitFormatter.formatBalance(_availableBalance, _activeUnit).replaceAll(',', '');
    setState(() {
      _errorMessage = null;
    });
  }

  /// Navegar al modo offline para seleccionar proofs manualmente.
  void _goToOfflineMode() {
    final walletProvider = context.read<WalletProvider>();
    final mintUrl = walletProvider.activeMintUrl;

    if (mintUrl == null) {
      setState(() {
        _errorMessage = 'No hay mint activo';
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
        _errorMessage = 'No hay mint activo';
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
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      // Crear token real con cdk-flutter
      final memo = _memoController.text.isNotEmpty ? _memoController.text : null;
      final amount = _amount;
      final token = await walletProvider.sendTokens(amount, memo);

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
    } catch (e) {
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

      setState(() {
        if (errorStr.contains('insufficient') || errorStr.contains('not enough')) {
          _errorMessage = 'Balance insuficiente';
        } else {
          _errorMessage = 'Error al crear token: $e';
        }
      });
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
        _errorMessage = 'No hay mint activo';
      });
      return;
    }

    // Mostrar snackbar informativo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sin conexion. Usando modo offline...'),
        backgroundColor: AppColors.primaryAction,
        duration: Duration(seconds: 2),
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
          const Text(
            'Confirmar envio',
            style: TextStyle(
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
                child: PrimaryButton(
                  text: 'Confirmar',
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
