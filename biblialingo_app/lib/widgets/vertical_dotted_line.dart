import 'package:flutter/material.dart';

class VerticalDottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dotSize;
  final double spacing;

  const VerticalDottedLine({
    super.key,
    this.height = 70.0,
    this.color = const Color(0xFFBCCEEA),
    this.dotSize = 5.0,
    this.spacing = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size(2, height),
        painter: _DottedLinePainter(
          color: color,
          dotSize: dotSize,
          spacing: spacing,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double spacing;

  _DottedLinePainter({
    required this.color,
    required this.dotSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.round;

    final totalSpacing = dotSize + spacing;
    int numberOfDots = (size.height / totalSpacing).ceil();

    for (int i = 0; i < numberOfDots; i++) {
      final dy = (i * totalSpacing) + (dotSize / 2);
      if (dy < size.height) {
        canvas.drawCircle(Offset(size.width / 2, dy), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.spacing != spacing;
  }
}

/// Línea de conexión suave entre dos nubes en zigzag.
/// Usa una curva de Bézier cúbica (efecto sigmoide) y coloca puntos
/// exactamente sobre la curva via PathMetrics.getTangentForOffset.
///
/// [fromLeft] = true:  nube de arriba a la IZQUIERDA → curva izq→der
/// [fromLeft] = false: nube de arriba a la DERECHA  → curva der→izq
class DiagonalDottedLine extends StatelessWidget {
  final bool fromLeft;
  final double height;
  final Color color;

  const DiagonalDottedLine({
    super.key,
    required this.fromLeft,
    this.height = 65.0,
    this.color = const Color(0xFFB0C4D8),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BezierDottedPainter(fromLeft: fromLeft, color: color),
      ),
    );
  }
}

class _BezierDottedPainter extends CustomPainter {
  final bool fromLeft;
  final Color color;

  _BezierDottedPainter({required this.fromLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Centro X de cada nube:
    // Izquierda: padding(12) + cloudW(140)/2 ≈ 21% del ancho de pantalla
    // Derecha:   ancho - mismo valor ≈ 79%
    final double leftX = size.width * 0.21;
    final double rightX = size.width * 0.79;

    final startX = fromLeft ? leftX : rightX;
    final endX = fromLeft ? rightX : leftX;

    // Bezier cúbico con puntos de control que crean una "S" suave:
    // cp1 mantiene la tangente vertical al inicio,
    // cp2 la mantiene vertical al final.
    final path = Path();
    path.moveTo(startX, 0);
    path.cubicTo(
      startX, size.height * 0.5,
      endX,   size.height * 0.5,
      endX,   size.height,
    );

    // Dibujar puntos a lo largo de la curva usando PathMetrics
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final paint = Paint()..color = color;

    for (final metric in metrics) {
      double distance = 0;
      const dotSpacing = 11.0;

      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 3.5, paint);
        }
        distance += dotSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(_BezierDottedPainter old) =>
      old.fromLeft != fromLeft || old.color != color;
}
