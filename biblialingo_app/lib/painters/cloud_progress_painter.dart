import 'package:flutter/material.dart';

/// Construye la forma de la nube uniendo 3 círculos solapados:
/// un cuerpo grande en la parte baja y dos "bumps" en la parte superior.
/// Usando Path.combine(union) se obtiene un contorno limpio y continuo,
/// compatible con PathMetrics para el trazo de progreso.
class CloudProgressPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final bool isUnlocked;
  final Color fillColor;
  final Color strokeColor;
  final Color progressColor;
  final double strokeWidth;

  const CloudProgressPainter({
    required this.progress,
    required this.isUnlocked,
    required this.fillColor,
    required this.strokeColor,
    this.progressColor = const Color(0xFFFF9800),
    this.strokeWidth = 5.5,
  });

  Path _buildCloudPath(Size size) {
    final w = size.width;
    final h = size.height;

    // Cuerpo principal (círculo grande, parte inferior-central)
    final body = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(w * 0.50, h * 0.63),
        radius: w * 0.31,
      ));

    // Bump izquierdo (bump superior-izquierdo)
    final leftBump = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(w * 0.26, h * 0.43),
        radius: w * 0.22,
      ));

    // Bump derecho (bump superior-derecho)
    final rightBump = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(w * 0.72, h * 0.41),
        radius: w * 0.22,
      ));

    // Unión de los 3 círculos → silueta limpia de nube
    return Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, body, leftBump),
      rightBump,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildCloudPath(size);

    // 1. Relleno sólido
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 2. Trazo exterior
    if (isUnlocked) {
      _paintProgressStroke(canvas, path);
    } else {
      // Bloqueado: solo contorno gris
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _paintProgressStroke(Canvas canvas, Path cloudPath) {
    // Contorno de fondo (sutil) cuando no está al 100%
    if (progress < 1.0) {
      canvas.drawPath(
        cloudPath,
        Paint()
          ..color = strokeColor.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (progress <= 0) return;

    // Calcular longitud total del path
    final metrics = cloudPath.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final totalLength = metrics.fold(0.0, (sum, m) => sum + m.length);
    if (totalLength == 0) return;

    final targetLength = totalLength * progress.clamp(0.0, 1.0);

    // Extraer el segmento proporcional al progreso
    final progressPath = Path();
    double accumulated = 0.0;

    for (final metric in cloudPath.computeMetrics()) {
      if (accumulated >= targetLength) break;
      final remaining = targetLength - accumulated;
      final extract = remaining < metric.length ? remaining : metric.length;
      progressPath.addPath(metric.extractPath(0, extract), Offset.zero);
      accumulated += metric.length;
    }

    canvas.drawPath(
      progressPath,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(CloudProgressPainter old) =>
      old.progress != progress ||
      old.isUnlocked != isUnlocked ||
      old.fillColor != fillColor ||
      old.strokeColor != strokeColor;
}
