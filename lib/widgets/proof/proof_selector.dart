import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/proof.dart';
import '../../core/utils/formatters.dart';

/// Widget para seleccionar proofs (notas de ecash) manualmente.
/// Cada proof se muestra como un chip que cambia de color al seleccionar.
class ProofSelector extends StatelessWidget {
  /// Lista de proofs disponibles.
  final List<LocalProof> proofs;

  /// Set de proofs actualmente seleccionados (por yHex).
  final Set<String> selectedIds;

  /// Unidad para formatear (sat, usd, eur).
  final String unit;

  /// Callback cuando se selecciona/deselecciona un proof.
  final void Function(LocalProof proof) onToggle;

  const ProofSelector({
    super.key,
    required this.proofs,
    required this.selectedIds,
    required this.unit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (proofs.isEmpty) {
      return _buildEmptyState();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: proofs.map((proof) {
        final isSelected = selectedIds.contains(proof.yHex);
        return _ProofChip(
          proof: proof,
          unit: unit,
          isSelected: isSelected,
          onTap: () => onToggle(proof),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No hay notas disponibles',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip individual para un proof.
class _ProofChip extends StatelessWidget {
  final LocalProof proof;
  final String unit;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProofChip({
    required this.proof,
    required this.unit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formatear el monto según la unidad
    final displayAmount = _formatAmount(proof.amount, unit);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Color de fondo: naranja si seleccionado, glass si no
          color: isSelected
              ? AppColors.primaryAction
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAction
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          // Sombra sutil cuando seleccionado
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAction.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          displayAmount,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Formatea el monto según la unidad.
  /// sat: "512", usd/eur: "5.12"
  String _formatAmount(BigInt amount, String unit) {
    final multiplier = UnitFormatter.getMultiplier(unit);

    if (multiplier == 100) {
      // USD/EUR: mostrar como decimal
      final value = amount.toDouble() / 100;
      return value.toStringAsFixed(2);
    } else {
      // SAT: mostrar como entero
      return amount.toString();
    }
  }
}

/// Widget que muestra el total seleccionado.
class ProofTotalDisplay extends StatelessWidget {
  final BigInt total;
  final String unit;

  const ProofTotalDisplay({
    super.key,
    required this.total,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTotal = UnitFormatter.formatBalance(total, unit);
    final unitLabel = UnitFormatter.getUnitLabel(unit);

    return Text(
      '$formattedTotal $unitLabel',
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
