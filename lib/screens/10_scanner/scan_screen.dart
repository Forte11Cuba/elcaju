import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/incoming_data_parser.dart';
import '../../widgets/scanner/qr_scanner_widget.dart';
import '../../providers/wallet_provider.dart';
import '../4_receive/receive_screen.dart';
import '../7_melt/melt_screen.dart';

/// Pantalla de escaneo QR con soporte para diferentes modos
class ScanScreen extends StatefulWidget {
  /// Modo de escaneo
  final ScanMode mode;

  /// Callback cuando se detecta un dato válido (para modos específicos)
  final void Function(String data)? onDataScanned;

  const ScanScreen({
    super.key,
    this.mode = ScanMode.any,
    this.onDataScanned,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _getTitleForMode(l10n),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Scanner
          QrScannerWidget(
            onDetect: _onCodeDetected,
            showFlashControl: true,
            showCameraSwitch: false,
          ),

          // Instrucciones en la parte inferior
          Positioned(
            bottom: 100,
            left: 24,
            right: 24,
            child: Text(
              _getInstructionForMode(l10n),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Indicador de procesamiento
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryAction,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTitleForMode(L10n l10n) {
    switch (widget.mode) {
      case ScanMode.any:
        return l10n.scanQrCode;
      case ScanMode.cashuOnly:
        return l10n.scanCashuToken;
      case ScanMode.invoiceOnly:
        return l10n.scanLightningInvoice;
    }
  }

  String _getInstructionForMode(L10n l10n) {
    switch (widget.mode) {
      case ScanMode.any:
        return l10n.pointCameraAtQr;
      case ScanMode.cashuOnly:
        return l10n.pointCameraAtCashuQr;
      case ScanMode.invoiceOnly:
        return l10n.pointCameraAtInvoiceQr;
    }
  }

  void _onCodeDetected(String rawData) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Parsear los datos
      final parsed = IncomingDataParser.parse(rawData);

      // Verificar si es válido para el modo actual
      if (!IncomingDataParser.isValidForMode(parsed, widget.mode)) {
        _showInvalidTypeError(parsed.type);
        return; // finally se encarga de setState
      }

      // Procesar según el tipo y modo
      await _processData(parsed);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processData(ParsedData data) async {
    switch (widget.mode) {
      case ScanMode.any:
        await _handleAnyMode(data);
        break;
      case ScanMode.cashuOnly:
        _handleCashuOnlyMode(data);
        break;
      case ScanMode.invoiceOnly:
        _handleInvoiceOnlyMode(data);
        break;
    }
  }

  Future<void> _handleAnyMode(ParsedData data) async {
    final l10n = L10n.of(context)!;

    switch (data.type) {
      case IncomingDataType.cashuToken:
        // Navegar a ReceiveScreen con el token pre-cargado
        if (mounted) {
          Navigator.pop(context); // Cerrar scanner
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiveScreen(initialToken: data.raw),
            ),
          );
        }
        break;

      case IncomingDataType.lightningInvoice:
        // Navegar a MeltScreen con el invoice pre-cargado
        if (mounted) {
          Navigator.pop(context); // Cerrar scanner
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeltScreen(initialInvoice: data.invoiceBolt11),
            ),
          );
        }
        break;

      case IncomingDataType.mintUrl:
        // Mostrar diálogo para agregar mint
        if (mounted) {
          await _showAddMintDialog(data.mintUrl!);
        }
        break;

      case IncomingDataType.paymentRequest:
        // TODO: Implementar manejo de payment requests (post-MVP)
        _showError(l10n.paymentRequestNotSupported);
        break;

      case IncomingDataType.unknown:
        // Si es una URL https, intentar verificar si es un mint
        if (data.raw.toLowerCase().startsWith('https://')) {
          await _tryVerifyAndAddMint(data.raw);
        } else {
          _showError(l10n.unrecognizedQrCode);
        }
        break;
    }
  }

  void _handleCashuOnlyMode(ParsedData data) {
    if (data.type == IncomingDataType.cashuToken) {
      // Retornar el token vía callback
      Navigator.pop(context, data.raw);
      widget.onDataScanned?.call(data.raw);
    } else {
      _showInvalidTypeError(data.type);
    }
  }

  void _handleInvoiceOnlyMode(ParsedData data) {
    if (data.type == IncomingDataType.lightningInvoice) {
      // Retornar el invoice vía callback
      Navigator.pop(context, data.invoiceBolt11 ?? data.raw);
      widget.onDataScanned?.call(data.invoiceBolt11 ?? data.raw);
    } else {
      _showInvalidTypeError(data.type);
    }
  }

  /// Intenta verificar si una URL es un mint válido antes de mostrar el diálogo
  Future<void> _tryVerifyAndAddMint(String rawUrl) async {
    final l10n = L10n.of(context)!;

    try {
      // Extraer URL base
      final uri = Uri.parse(rawUrl);
      String mintUrl = '${uri.scheme}://${uri.host}';
      if (uri.port != 443 && uri.port != 0) {
        mintUrl += ':${uri.port}';
      }

      // Verificar si es un mint real (timeout corto)
      final walletProvider = context.read<WalletProvider>();
      final isValidMint = await walletProvider.canReachMint(mintUrl);

      if (!mounted) return;

      if (isValidMint) {
        // Es un mint válido → mostrar diálogo
        await _showAddMintDialog(mintUrl);
      } else {
        // No es un mint → QR no reconocido
        _showError(l10n.unrecognizedQrCode);
      }
    } catch (_) {
      if (mounted) {
        _showError(l10n.unrecognizedQrCode);
      }
    }
  }

  Future<void> _showAddMintDialog(String mintUrl) async {
    final l10n = L10n.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepVoidPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.addMintQuestion,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mintUrl,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.add,
              style: const TextStyle(color: AppColors.primaryAction),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final walletProvider = context.read<WalletProvider>();
        await walletProvider.addMint(mintUrl);

        if (mounted) {
          Navigator.pop(context); // Cerrar scanner
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mintAddedSuccessfully),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        _showError(l10n.couldNotConnectToMint);
      }
    }
  }

  void _showInvalidTypeError(IncomingDataType detectedType) {
    final l10n = L10n.of(context)!;

    String message;
    switch (widget.mode) {
      case ScanMode.cashuOnly:
        message = l10n.scanCashuTokenHint;
        break;
      case ScanMode.invoiceOnly:
        message = l10n.scanLightningInvoiceHint;
        break;
      case ScanMode.any:
        message = l10n.unrecognizedQrCode;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
