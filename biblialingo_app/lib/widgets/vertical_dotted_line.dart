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

/// Línea punteada diagonal entre dos nubes en zigzag.
/// [fromLeft] = true: empieza en el lado izquierdo (nube izquierda arriba → derecha abajo)
/// [fromLeft] = false: empieza en el lado derecho (nube derecha arriba → izquierda abajo)
class DiagonalDottedLine extends StatelessWidget {
  final bool fromLeft;
  final double height;
  final Color color;

  const DiagonalDottedLine({
    super.key,
    required this.fromLeft,
    this.height = 55.0,
    this.color = const Color(0xFFBCCEEA),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DiagonalDottedPainter(fromLeft: fromLeft, color: color),
      ),
    );
  }
}

class _DiagonalDottedPainter extends CustomPainter {
  final bool fromLeft;
  final Color color;

  _DiagonalDottedPainter({required this.fromLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Posiciones aproximadas del centro de la nube como fracción del ancho
    const leftCenterFrac = 0.22;
    const rightCenterFrac = 0.78;

    final startX = fromLeft
        ? size.width * leftCenterFrac
        : size.width * rightCenterFrac;
    final endX = fromLeft
        ? size.width * rightCenterFrac
        : size.width * leftCenterFrac;

    const numDots = 9;
    for (int i = 0; i <= numDots; i++) {
      final t = i / numDots;
      final x = startX + (endX - startX) * t;
      final y = size.height * t;
      canvas.drawCircle(Offset(x, y), 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(_DiagonalDottedPainter old) =>
      old.fromLeft != fromLeft || old.color != color;
}
