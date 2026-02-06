import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cdk_flutter/cdk_flutter.dart' show MintInfo, ContactInfo;
import '../../core/constants/colors.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common/gradient_background.dart';

/// Pantalla de detalles de un mint (estilo cashu.me)
class MintDetailScreen extends StatefulWidget {
  final String mintUrl;
  final MintInfo? mintInfo;
  final bool isActive;
  final Map<String, BigInt> balances;
  final VoidCallback? onSetActive;
  final VoidCallback? onDelete;

  const MintDetailScreen({
    super.key,
    required this.mintUrl,
    this.mintInfo,
    this.isActive = false,
    this.balances = const {},
    this.onSetActive,
    this.onDelete,
  });

  @override
  State<MintDetailScreen> createState() => _MintDetailScreenState();
}

class _MintDetailScreenState extends State<MintDetailScreen> {
  bool _motdDismissed = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.mintInfo;
    final name = info?.name ?? UnitFormatter.getMintDisplayName(widget.mintUrl);
    final motd = info?.motd;
    final hasMotd = motd != null && motd.isNotEmpty && !_motdDismissed;

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
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Header: Logo + Nombre
                _buildHeader(name, info?.iconUrl),

                const SizedBox(height: 24),

                // MOTD Banner (si existe)
                if (hasMotd) _buildMotdBanner(motd),

                // Descripción (si existe)
                if (info?.description != null && info!.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDescription(info.description!),
                ],

                // Sección CONTACT
                if (info?.contact != null && info!.contact!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionDivider('CONTACT'),
                  const SizedBox(height: 16),
                  _buildContactSection(info.contact!),
                ],

                // Sección MINT DETAILS
                const SizedBox(height: 24),
                _buildSectionDivider('MINT DETAILS'),
                const SizedBox(height: 16),
                _buildMintDetails(info),

                // Sección ACTIONS
                const SizedBox(height: 24),
                _buildSectionDivider('ACTIONS'),
                const SizedBox(height: 16),
                _buildActions(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String? iconUrl) {
    return Column(
      children: [
        // Logo
        Container(
          width: 72,
          height: 72,
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
                      size: 36,
                    ),
                  ),
                )
              : const Icon(
                  LucideIcons.landmark,
                  color: AppColors.primaryAction,
                  size: 36,
                ),
        ),
        const SizedBox(height: 16),
        // Nombre
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        // Badge activo
        if (widget.isActive) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Mint activo',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMotdBanner(String motd) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF18408).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF18408).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.info,
            color: Color(0xFFF18408),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mint Message',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF18408),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  motd,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _motdDismissed = true),
            child: Icon(
              LucideIcons.x,
              color: Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(List<ContactInfo> contacts) {
    return Column(
      children: contacts.map((contact) {
        final icon = _getContactIcon(contact.method);
        final value = contact.info;

        return _buildCopyableRow(
          icon: icon,
          label: value,
          onCopy: () => _copyToClipboard(value, contact.method),
        );
      }).toList(),
    );
  }

  IconData _getContactIcon(String method) {
    switch (method.toLowerCase()) {
      case 'email':
        return LucideIcons.mail;
      case 'twitter':
      case 'x':
        return LucideIcons.atSign;
      case 'nostr':
        return LucideIcons.key;
      default:
        return LucideIcons.link;
    }
  }

  Widget _buildMintDetails(MintInfo? info) {
    // Obtener currency de los balances
    final currencies = widget.balances.keys.join(', ').toUpperCase();
    final currencyDisplay = currencies.isNotEmpty ? currencies : 'SAT';

    // Versión del mint
    final version = info?.version != null
        ? '${info!.version!.name}/${info.version!.version}'
        : 'Unknown';

    return Column(
      children: [
        _buildDetailRow(
          icon: LucideIcons.link,
          label: 'URL',
          value: widget.mintUrl,
          canCopy: true,
        ),
        _buildDetailRow(
          icon: LucideIcons.coins,
          label: 'Currency',
          value: currencyDisplay,
        ),
        _buildDetailRow(
          icon: LucideIcons.box,
          label: 'Version',
          value: version,
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          if (canCopy) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _copyToClipboard(value, label),
              child: Icon(
                LucideIcons.copy,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyableRow({
    required IconData icon,
    required String label,
    required VoidCallback onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                LucideIcons.copy,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Usar este mint (si no es el activo)
        if (!widget.isActive && widget.onSetActive != null)
          _buildActionButton(
            icon: LucideIcons.star,
            label: 'Usar este mint',
            onTap: () {
              widget.onSetActive!();
              Navigator.pop(context);
            },
          ),

        // Copiar URL
        _buildActionButton(
          icon: LucideIcons.copy,
          label: 'Copiar URL del mint',
          onTap: () => _copyToClipboard(widget.mintUrl, 'URL'),
        ),

        // Eliminar mint
        if (widget.onDelete != null)
          _buildActionButton(
            icon: LucideIcons.trash2,
            label: 'Eliminar mint',
            isDestructive: true,
            onTap: () => _showDeleteConfirmation(),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepVoidPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Eliminar mint',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Si tienes balance en este mint, se perderá. ¿Estás seguro?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a lista
              widget.onDelete!();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
