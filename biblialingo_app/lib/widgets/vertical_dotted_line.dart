import 'package:flutter/material.dart';

/// Widget que dibuja una línea punteada vertical entre lecciones
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

/// CustomPainter para dibujar la línea punteada
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

    // Calcular número de puntos que caben en la altura
    final totalSpacing = dotSize + spacing;
    int numberOfDots = (size.height / totalSpacing).ceil();

    // Dibujar los puntos
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
