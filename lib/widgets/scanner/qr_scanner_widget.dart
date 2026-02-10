import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cdk_flutter/cdk_flutter.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/incoming_data_parser.dart';

/// Widget reutilizable para escanear QR codes
/// Soporta QR estáticos y animados (UR multipartes)
class QrScannerWidget extends StatefulWidget {
  /// Callback cuando se detecta un código completo
  final void Function(String data) onDetect;

  /// Callback para mostrar errores
  final void Function(String error)? onError;

  /// Mostrar controles de flash (default: true)
  final bool showFlashControl;

  /// Mostrar botón para cambiar cámara (default: false)
  final bool showCameraSwitch;

  const QrScannerWidget({
    super.key,
    required this.onDetect,
    this.onError,
    this.showFlashControl = true,
    this.showCameraSwitch = false,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  late MobileScannerController _controller;

  // Estado para QR animados (UR multipartes) usando TokenDecoder de cdk-flutter
  TokenDecoder? _urDecoder;
  bool _isCapturingUr = false;
  final Set<String> _urFragmentsSeen = {};  // Trackear fragmentos únicos

  // Evitar procesar el mismo código múltiples veces
  String? _lastProcessedCode;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
      // Usar resolución más alta para QRs densos
      cameraResolution: const Size(1920, 1080),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    // Evitar procesar el mismo código consecutivamente
    if (rawValue == _lastProcessedCode) return;
    _lastProcessedCode = rawValue;

    // Verificar si es un fragmento UR (ur:bytes/, ur:cashu/, etc.)
    if (rawValue.toLowerCase().startsWith('ur:')) {
      _handleUrFragment(rawValue);
    } else {
      // QR simple - emitir directamente
      _resetUrState();
      widget.onDetect(rawValue);
    }
  }

  void _handleUrFragment(String fragment) {
    // Inicializar decoder si es necesario
    if (_urDecoder == null) {
      _urDecoder = TokenDecoder();
      _isCapturingUr = true;
      _urFragmentsSeen.clear();
    }

    // Ignorar fragmentos ya vistos
    if (_urFragmentsSeen.contains(fragment)) {
      return;
    }

    // Pasar fragmento al decoder (usa fountain codes internamente)
    try {
      _urDecoder!.receive(input: fragment);
      _urFragmentsSeen.add(fragment);
    } catch (e) {
      // Fragmento inválido o incompatible, ignorar
      return;
    }

    // Actualizar UI
    if (mounted) setState(() {});

    // Verificar si está completo
    if (_urDecoder!.isComplete()) {
      try {
        final token = _urDecoder!.value();
        if (token != null) {
          final encodedToken = token.encoded;
          _resetUrState();
          widget.onDetect(encodedToken);
        } else {
          widget.onError?.call('Error: token vacío');
          _resetUrState();
        }
      } catch (e) {
        widget.onError?.call('Error decodificando UR: $e');
        _resetUrState();
      }
    }
  }

  void _resetUrState() {
    _urDecoder = null;
    _isCapturingUr = false;
    _urFragmentsSeen.clear();
    _lastProcessedCode = null;
  }

  void _toggleFlash() async {
    await _controller.toggleTorch();
  }

  void _switchCamera() async {
    await _controller.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scanner
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error, child) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.cameraOff,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error.errorDetails?.message ??
                        L10n.of(context)!.cameraPermissionDenied,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),

        // Overlay con visor
        _buildOverlay(),

        // Indicador de progreso UR (si está capturando)
        if (_isCapturingUr) _buildUrProgress(),

        // Controles
        _buildControls(),
      ],
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scannerSize = constraints.maxWidth * 0.7;
        final horizontalPadding = (constraints.maxWidth - scannerSize) / 2;
        final verticalPadding = (constraints.maxHeight - scannerSize) / 2;

        return Stack(
          children: [
            // Sombra superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: verticalPadding,
              child: Container(color: Colors.black54),
            ),
            // Sombra inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: verticalPadding,
              child: Container(color: Colors.black54),
            ),
            // Sombra izquierda
            Positioned(
              top: verticalPadding,
              left: 0,
              width: horizontalPadding,
              height: scannerSize,
              child: Container(color: Colors.black54),
            ),
            // Sombra derecha
            Positioned(
              top: verticalPadding,
              right: 0,
              width: horizontalPadding,
              height: scannerSize,
              child: Container(color: Colors.black54),
            ),
            // Marco del visor
            Positioned(
              top: verticalPadding,
              left: horizontalPadding,
              child: Container(
                width: scannerSize,
                height: scannerSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isCapturingUr
                        ? AppColors.warning
                        : AppColors.primaryAction,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Esquinas decorativas
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final color = _isCapturingUr ? AppColors.warning : AppColors.primaryAction;
    const size = 24.0;
    const thickness = 4.0;

    return Positioned(
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight
          ? 0
          : null,
      bottom:
          alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
              ? 0
              : null,
      left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
          ? 0
          : null,
      right:
          alignment == Alignment.topRight || alignment == Alignment.bottomRight
              ? 0
              : null,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CornerPainter(
            color: color,
            thickness: thickness,
            alignment: alignment,
          ),
        ),
      ),
    );
  }

  Widget _buildUrProgress() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QR Animado',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_urFragmentsSeen.length} fragmentos',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Indicador indeterminado ya que TokenDecoder no expone progreso
            const LinearProgressIndicator(
              backgroundColor: Colors.black26,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showFlashControl)
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                final torchEnabled = state.torchState == TorchState.on;
                return GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: torchEnabled
                          ? AppColors.warning
                          : Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      torchEnabled ? LucideIcons.zapOff : LucideIcons.zap,
                      color: torchEnabled ? Colors.black : Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          if (widget.showFlashControl && widget.showCameraSwitch)
            const SizedBox(width: 24),
          if (widget.showCameraSwitch)
            GestureDetector(
              onTap: _switchCamera,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.switchCamera,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Painter para dibujar esquinas decorativas
class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Alignment alignment;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.alignment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      color != oldDelegate.color;
}
