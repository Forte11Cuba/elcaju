import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/nostr_utils.dart';
import '../../providers/p2pk_provider.dart';
import '../../models/p2pk_key.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/glass_card.dart';

/// Pantalla para gestionar claves P2PK
class P2PKKeysScreen extends StatefulWidget {
  const P2PKKeysScreen({super.key});

  @override
  State<P2PKKeysScreen> createState() => _P2PKKeysScreenState();
}

class _P2PKKeysScreenState extends State<P2PKKeysScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

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
            l10n.p2pkTitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Consumer<P2PKProvider>(
            builder: (context, p2pkProvider, child) {
              if (!p2pkProvider.isInitialized) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAction,
                  ),
                );
              }

              return Column(
                children: [
                  // Contenido scrolleable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Banner experimental
                          _buildExperimentalBanner(l10n),
                          const SizedBox(height: AppDimensions.paddingMedium),

                          // Clave principal
                          if (p2pkProvider.primaryKey != null) ...[
                            _buildSectionHeader(l10n.p2pkPrimaryKey),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            _buildKeyCard(p2pkProvider.primaryKey!, p2pkProvider, l10n),
                            const SizedBox(height: AppDimensions.paddingLarge),
                          ],

                          // Claves importadas
                          _buildSectionHeader(l10n.p2pkImportedKeys),
                          const SizedBox(height: AppDimensions.paddingSmall),

                          if (p2pkProvider.importedKeys.isEmpty)
                            _buildEmptyImportedState(l10n)
                          else
                            ...p2pkProvider.importedKeys.map(
                              (key) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.paddingSmall,
                                ),
                                child: _buildKeyCard(key, p2pkProvider, l10n),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Botón importar (fijo abajo)
                  if (p2pkProvider.canImportMore)
                    Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: _buildImportButton(p2pkProvider, l10n),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExperimentalBanner(L10n l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.flaskConical,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.p2pkExperimental,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildKeyCard(P2PKKey key, P2PKProvider provider, L10n l10n) {
    String truncatedNpub;
    try {
      final npub = NostrUtils.hexToNpub(key.publicKey);
      truncatedNpub = '${npub.substring(0, 12)}...${npub.substring(npub.length - 8)}';
    } catch (_) {
      truncatedNpub = key.publicKey.length > 16
          ? '${key.publicKey.substring(0, 16)}...'
          : key.publicKey;
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con label y badge
          Row(
            children: [
              Expanded(
                child: Text(
                  key.label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: key.isDerived
                      ? AppColors.primaryAction.withValues(alpha: 0.2)
                      : AppColors.secondaryAction.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  key.isDerived ? l10n.p2pkDerived : l10n.p2pkImported,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: key.isDerived
                        ? AppColors.primaryAction
                        : AppColors.secondaryAction,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // npub (tap to copy)
          GestureDetector(
            onTap: () {
              final fullNpub = _safeNpub(key.publicKey);
              Clipboard.setData(ClipboardData(text: fullNpub));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.copied('npub')),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.key,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      truncatedNpub,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.copy,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Acciones
          Row(
            children: [
              // Mostrar QR
              Expanded(
                child: GestureDetector(
                  onTap: () => _showQRDialog(key, l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.qrCode,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.p2pkShowQR,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Eliminar (solo para importadas)
              if (!key.isDerived) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showDeleteDialog(key, provider, l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.trash2,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImportedState(L10n l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.keyRound,
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.p2pkNoImportedKeys,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton(P2PKProvider provider, L10n l10n) {
    return GestureDetector(
      onTap: () => _showImportDialog(provider, l10n),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryAction, Color(0xFFFF9100)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.plus, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.p2pkImportNsec,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ DIÁLOGOS ============

  void _showQRDialog(P2PKKey key, L10n l10n) {
    final npub = _safeNpub(key.publicKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepVoidPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                key.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: npub,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: npub));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.copied('npub')),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.copy,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.p2pkCopy,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.close,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(P2PKProvider provider, L10n l10n) {
    final nsecController = TextEditingController();
    final labelController = TextEditingController();
    bool obscureNsec = true;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final nsecBorder = OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: errorMessage != null
                ? const BorderSide(color: AppColors.error)
                : BorderSide.none,
          );
          return AlertDialog(
          backgroundColor: AppColors.deepVoidPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            l10n.p2pkImportNsec,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Label
                TextField(
                  controller: labelController,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.p2pkEnterLabel,
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
                    prefixIcon: Icon(
                      LucideIcons.tag,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // nsec input
                TextField(
                  controller: nsecController,
                  obscureText: obscureNsec,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'nsec1...',
                    hintStyle: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: nsecBorder,
                    enabledBorder: nsecBorder,
                    focusedBorder: nsecBorder,
                    prefixIcon: Icon(
                      LucideIcons.keyRound,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            obscureNsec ? LucideIcons.eye : LucideIcons.eyeOff,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            setDialogState(() => obscureNsec = !obscureNsec);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            LucideIcons.clipboard,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              nsecController.text = data!.text!;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Error message
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await provider.importFromNsec(
                    nsecController.text.trim(),
                    labelController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.success),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } on P2PKException catch (e) {
                  setDialogState(() {
                    errorMessage = _getErrorMessage(e.code, l10n);
                  });
                }
              },
              child: Text(
                l10n.p2pkImport,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryAction,
                ),
              ),
            ),
          ],
        );
        },
      ),
    );
  }

  void _showDeleteDialog(P2PKKey key, P2PKProvider provider, L10n l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepVoidPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.p2pkDeleteTitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          l10n.p2pkDeleteConfirm,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await provider.removeKey(key.id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.error),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Convierte hex a npub de forma segura, retornando el hex como fallback.
  String _safeNpub(String hex) {
    try {
      return NostrUtils.hexToNpub(hex);
    } catch (_) {
      return hex;
    }
  }

  String _getErrorMessage(P2PKErrorCode code, L10n l10n) {
    switch (code) {
      case P2PKErrorCode.maxKeysReached:
        return l10n.p2pkErrorMaxKeysReached;
      case P2PKErrorCode.invalidNsec:
        return l10n.p2pkErrorInvalidNsec;
      case P2PKErrorCode.keyAlreadyExists:
        return l10n.p2pkErrorKeyAlreadyExists;
      case P2PKErrorCode.keyNotFound:
        return l10n.p2pkErrorKeyNotFound;
      case P2PKErrorCode.cannotDeletePrimaryKey:
        return l10n.p2pkErrorCannotDeletePrimary;
    }
  }
}
