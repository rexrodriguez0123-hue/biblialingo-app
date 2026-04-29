import 'package:flutter/material.dart';
import 'dart:math' as math;

/// CustomPainter para dibujar un trazo circular de progreso alrededor de una nube
class CloudProgressPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final bool isUnlocked;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  CloudProgressPainter({
    required this.progress,
    required this.isUnlocked,
    this.strokeWidth = 8.0,
    this.progressColor = const Color(0xFFFF9800), // Naranja
    this.backgroundColor = const Color(0xFF0277BD), // Azul
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - (strokeWidth / 2);

    // Pintar el trazo de fondo (círculo gris muy claro)
    if (!isUnlocked) {
      _paintBackgroundCircle(canvas, center, radius);
    } else {
      _paintProgressArc(canvas, center, radius);
    }
  }

  /// Pinta un círculo completo de fondo gris cuando está bloqueado
  void _paintBackgroundCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC) // Gris claro
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  /// Pinta el arco de progreso
  void _paintProgressArc(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Arco de progreso (naranja si hay progreso, azul si sin progreso)
    if (progress > 0) {
      paint.color = progressColor; // Naranja si hay progreso
    } else {
      paint.color = backgroundColor; // Azul si sin progreso
    }

    // Calcular el ángulo: -90° comienza en la parte superior
    const startAngle = -math.pi / 2; // Comienza en top (12 o'clock)
    final sweepAngle = ((progress * 2 * math.pi).clamp(0, 2 * math.pi)) as double;

    // Dibujar el arco
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Si está sin progreso pero desbloqueado, dibujar un círculo de fondo muy sutil
    if (progress == 0 && isUnlocked) {
      final backgroundPaint = Paint()
        ..color = const Color(0xFFE3F2FD) // Azul muy claro
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, radius, backgroundPaint);
    }
  }

  @override
  bool shouldRepaint(CloudProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isUnlocked != isUnlocked ||
        oldDelegate.progressColor != progressColor;
  }
}
