import 'package:flutter/material.dart';

/// CustomPainter para dibujar un trazo de progreso que sigue la forma de la nube
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

  /// Crea el path de la nube basado en el contorno SVG normalizado
  Path _createCloudPath(Size size) {
    final width = size.width;
    final height = size.height;
    
    final path = Path();
    
    // Punto de inicio: esquina derecha inferior
    path.moveTo(width * 0.95, height * 0.95);
    
    // Lado inferior: de derecha a izquierda
    path.quadraticBezierTo(
      width * 0.7, height * 1.0,
      width * 0.1, height * 0.95,
    );
    
    // Esquina inferior izquierda con bulge hacia afuera
    path.quadraticBezierTo(
      width * -0.05, height * 0.9,
      width * 0.05, height * 0.7,
    );
    
    // Lado izquierdo inferior: subiendo
    path.quadraticBezierTo(
      width * 0.02, height * 0.5,
      width * 0.05, height * 0.35,
    );
    
    // Bulge izquierdo
    path.quadraticBezierTo(
      width * -0.08, height * 0.25,
      width * 0.1, height * 0.15,
    );
    
    // Lado superior izquierdo
    path.quadraticBezierTo(
      width * 0.2, height * 0.02,
      width * 0.4, height * -0.02,
    );
    
    // Bulge superior izquierdo (parte superior de la nube)
    path.quadraticBezierTo(
      width * 0.5, height * -0.15,
      width * 0.6, height * -0.02,
    );
    
    // Bulge superior central
    path.quadraticBezierTo(
      width * 0.65, height * -0.1,
      width * 0.7, height * 0.02,
    );
    
    // Bulge superior derecho
    path.quadraticBezierTo(
      width * 0.8, height * -0.08,
      width * 0.9, height * 0.08,
    );
    
    // Lado derecho
    path.quadraticBezierTo(
      width * 1.05, height * 0.15,
      width * 1.02, height * 0.35,
    );
    
    // Lado derecho inferior
    path.quadraticBezierTo(
      width * 1.0, height * 0.6,
      width * 0.95, height * 0.95,
    );
    
    // Cerrar el path
    path.close();
    
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!isUnlocked) {
      _paintBackgroundCloud(canvas, size);
    } else {
      _paintProgressCloud(canvas, size);
    }
  }

  /// Pinta el contorno de la nube en gris cuando está bloqueado
  void _paintBackgroundCloud(Canvas canvas, Size size) {
    final path = _createCloudPath(size);
    
    final paint = Paint()
      ..color = const Color(0xFFCCCCCC) // Gris claro
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  /// Pinta el trazo de progreso que sigue el contorno de la nube
  void _paintProgressCloud(Canvas canvas, Size size) {
    final path = _createCloudPath(size);
    
    // Obtener las métricas del path para calcular la longitud total
    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isEmpty) return;
    
    double totalLength = 0;
    for (final metric in pathMetrics) {
      totalLength += metric.length;
    }

    if (totalLength == 0) return;

    // Dibujar el fondo (contorno completo muy sutil)
    if (progress < 1.0) {
      final backgroundPaint = Paint()
        ..color = const Color(0xFFE3F2FD) // Azul muy claro
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, backgroundPaint);
    }

    // Calcular la longitud del trazo de progreso
    final progressLength = totalLength * progress.clamp(0.0, 1.0);

    if (progressLength <= 0) return;

    // Extraer el segmento del path según el progreso
    final progressPath = Path();
    double accumulatedLength = 0;

    for (final metric in path.computeMetrics()) {
      final currentSegmentLength = metric.length;
      
      if (accumulatedLength + currentSegmentLength <= progressLength) {
        // Añadir el segmento completo
        progressPath.addPath(metric.extractPath(0, currentSegmentLength), Offset.zero);
        accumulatedLength += currentSegmentLength;
      } else {
        // Añadir solo una porción del segmento
        final remainingLength = progressLength - accumulatedLength;
        progressPath.addPath(metric.extractPath(0, remainingLength), Offset.zero);
        break;
      }
    }

    // Pintar el trazo de progreso
    final progressPaint = Paint()
      ..color = progress > 0 ? progressColor : backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(progressPath, progressPaint);
  }

  @override
  bool shouldRepaint(CloudProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isUnlocked != isUnlocked ||
        oldDelegate.progressColor != progressColor;
  }
}
