import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/models/proof.dart';
import '../../core/services/proof_service.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/proof/proof_selector.dart';
import 'share_token_screen.dart';

/// Pantalla para enviar tokens de forma offline seleccionando proofs manualmente.
class OfflineSendScreen extends StatefulWidget {
  final String mintUrl;
  final String unit;

  const OfflineSendScreen({
    super.key,
    required this.mintUrl,
    required this.unit,
  });

  @override
  State<OfflineSendScreen> createState() => _OfflineSendScreenState();
}

class _OfflineSendScreenState extends State<OfflineSendScreen> {
  final TextEditingController _memoController = TextEditingController();
  final ProofService _proofService = ProofService();

  List<LocalProof> _availableProofs = [];
  Set<String> _selectedIds = {};
  bool _isLoading = true;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProofs();
  }

  @override
  void dispose() {
    _memoController.dispose();
    _proofService.close();
    super.dispose();
  }

  Future<void> _loadProofs() async {
    try {
      final proofs = await _proofService.getUnspentProofs(
        mintUrl: widget.mintUrl,
        unit: widget.unit,
      );

      if (mounted) {
        setState(() {
          _availableProofs = proofs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cargando proofs: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Obtiene los proofs seleccionados.
  List<LocalProof> get _selectedProofs {
    return _availableProofs
        .where((p) => _selectedIds.contains(p.yHex))
        .toList();
  }

  /// Calcula el total seleccionado.
  BigInt get _selectedTotal {
    return _proofService.calculateTotal(_selectedProofs);
  }

  /// Toggle selección de un proof.
  void _toggleProof(LocalProof proof) {
    setState(() {
      if (_selectedIds.contains(proof.yHex)) {
        _selectedIds.remove(proof.yHex);
      } else {
        _selectedIds.add(proof.yHex);
      }
    });
  }

  /// Seleccionar todos.
  void _selectAll() {
    setState(() {
      _selectedIds = _availableProofs.map((p) => p.yHex).toSet();
    });
  }

  /// Deseleccionar todos.
  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

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
            'Envio Offline',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            // Botón seleccionar/deseleccionar todos
            if (_availableProofs.isNotEmpty)
              IconButton(
                icon: Icon(
                  _selectedIds.length == _availableProofs.length
                      ? LucideIcons.checkSquare
                      : LucideIcons.square,
                  color: AppColors.primaryAction,
                ),
                onPressed: _selectedIds.length == _availableProofs.length
                    ? _clearSelection
                    : _selectAll,
              ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? _buildLoading()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryAction,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total seleccionado
          _buildTotalDisplay(),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Instrucciones
          Text(
            'Selecciona las notas que deseas enviar:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Selector de proofs
          Expanded(
            child: SingleChildScrollView(
              child: GlassCard(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: ProofSelector(
                  proofs: _availableProofs,
                  selectedIds: _selectedIds,
                  unit: widget.unit,
                  onToggle: _toggleProof,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Memo opcional
          _buildMemoSection(),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Botón crear token
          PrimaryButton(
            text: _isCreating ? 'Creando...' : 'Crear token',
            onPressed: _selectedIds.isNotEmpty && !_isCreating
                ? _createOfflineToken
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDisplay() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Text(
            'Total a enviar',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ProofTotalDisplay(
            total: _selectedTotal,
            unit: widget.unit,
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedIds.length} notas seleccionadas',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      child: TextField(
        controller: _memoController,
        maxLines: 1,
        maxLength: 100,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'Memo (opcional)',
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
    );
  }

  Future<void> _createOfflineToken() async {
    setState(() {
      _isCreating = true;
    });

    try {
      final selectedProofs = _selectedProofs;

      // Marcar proofs como PENDING_SPENT
      await _proofService.markProofsPendingSpent(selectedProofs);

      // Crear token V3
      final memo = _memoController.text.isNotEmpty ? _memoController.text : null;
      final token = _proofService.createTokenV3(
        mintUrl: widget.mintUrl,
        proofs: selectedProofs,
        memo: memo,
        unit: widget.unit,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShareTokenScreen(
              token: token,
              amount: _selectedTotal,
              unit: widget.unit,
              memo: memo,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creando token: $e';
        _isCreating = false;
      });
    }
  }
}
