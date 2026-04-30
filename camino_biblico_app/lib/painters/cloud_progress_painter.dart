import 'package:flutter/material.dart';

/// Path de la nube usando curvas de Bézier cuadráticas —
/// basado en el ejemplo de referencia del proyecto.
/// Diseñado para un canvas rectangular (más ancho que alto).
Path buildCloudPath(Size size) {
  final w = size.width;
  final h = size.height;
  final path = Path();

  path.moveTo(w * 0.25, h * 0.85);
  path.quadraticBezierTo(w * 0.05, h * 0.85, w * 0.05, h * 0.65);
  path.quadraticBezierTo(w * 0.05, h * 0.45, w * 0.20, h * 0.40);
  path.quadraticBezierTo(w * 0.25, h * 0.10, w * 0.50, h * 0.15);
  path.quadraticBezierTo(w * 0.75, h * 0.10, w * 0.85, h * 0.35);
  path.quadraticBezierTo(w * 0.98, h * 0.45, w * 0.95, h * 0.70);
  path.quadraticBezierTo(w * 0.90, h * 0.90, w * 0.70, h * 0.85);
  path.close();

  return path;
}

/// Pinta el relleno + sombra de la nube.
class CloudFillPainter extends CustomPainter {
  final Color fillColor;
  final bool isLocked;

  const CloudFillPainter({required this.fillColor, this.isLocked = false});

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildCloudPath(size);

    // Sombra suave
    canvas.drawPath(
      path.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Relleno
    canvas.drawPath(path, Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill);

    // Borde sutil para nubes bloqueadas
    if (isLocked) {
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFFB0BEC5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
    }
  }

  @override
  bool shouldRepaint(CloudFillPainter old) => old.fillColor != fillColor;
}

/// Pinta el trazo de progreso que recorre el contorno de la nube.
class CloudProgressPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Color strokeColor;
  final double strokeWidth;

  const CloudProgressPainter({
    required this.progress,
    this.strokeColor = const Color(0xFF01579B),
    this.strokeWidth = 5.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final path = buildCloudPath(size);
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // PathMetrics: extraer solo la porción proporcional al progreso
    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      final extract = metric.extractPath(0.0, metric.length * progress.clamp(0.0, 1.0));
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(CloudProgressPainter old) =>
      old.progress != progress || old.strokeColor != strokeColor;
}
