import 'package:flutter/material.dart';
import 'package:torneo_leon_de_juda/core/theme/app_colors.dart';

/// Overlay sobre la cámara con un viewfinder cuadrado centrado y 4 esquinas
/// doradas. Oscurece el resto de la pantalla para enfocar la mirada del
/// usuario en el QR.
class ScannerOverlay extends StatelessWidget {
  const ScannerOverlay({
    this.boxSize = 260,
    this.cornerLength = 28,
    this.cornerThickness = 4,
    super.key,
  });

  final double boxSize;
  final double cornerLength;
  final double cornerThickness;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _OverlayPainter(
          boxSize: boxSize,
          cornerLength: cornerLength,
          cornerThickness: cornerThickness,
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.boxSize,
    required this.cornerLength,
    required this.cornerThickness,
  });

  final double boxSize;
  final double cornerLength;
  final double cornerThickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final box = Rect.fromCenter(
      center: center,
      width: boxSize,
      height: boxSize,
    );
    final rrect = RRect.fromRectAndRadius(box, const Radius.circular(16));

    // Capa oscura con hueco recortado.
    final darken = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, darken);

    // Esquinas doradas.
    final corner = Paint()
      ..color = AppColors.primary
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final l = cornerLength;

    canvas
      // Top-left
      ..drawLine(box.topLeft, box.topLeft + Offset(l, 0), corner)
      ..drawLine(box.topLeft, box.topLeft + Offset(0, l), corner)
      // Top-right
      ..drawLine(box.topRight, box.topRight + Offset(-l, 0), corner)
      ..drawLine(box.topRight, box.topRight + Offset(0, l), corner)
      // Bottom-left
      ..drawLine(box.bottomLeft, box.bottomLeft + Offset(l, 0), corner)
      ..drawLine(box.bottomLeft, box.bottomLeft + Offset(0, -l), corner)
      // Bottom-right
      ..drawLine(box.bottomRight, box.bottomRight + Offset(-l, 0), corner)
      ..drawLine(box.bottomRight, box.bottomRight + Offset(0, -l), corner);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.boxSize != boxSize ||
      old.cornerLength != cornerLength ||
      old.cornerThickness != cornerThickness;
}
