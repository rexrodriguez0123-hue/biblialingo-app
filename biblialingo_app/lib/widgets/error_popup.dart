import 'dart:math' as math;
import 'package:flutter/material.dart';

class ErrorPopup extends StatefulWidget {
  final String correctAnswer;
  final int remainingHearts;
  final VoidCallback onNext;

  const ErrorPopup({
    super.key,
    required this.correctAnswer,
    required this.remainingHearts,
    required this.onNext,
  });

  @override
  State<ErrorPopup> createState() => _ErrorPopupState();
}

class _ErrorPopupState extends State<ErrorPopup> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _shakeController.forward();

    // Broken heart slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Section (Broken Heart)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFEF2F2), Colors.white], // red-50 to white
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Particles background
                      ...List.generate(6, (index) {
                        return _FloatingParticle(
                          delay: index * 500,
                          leftPosition: math.Random().nextDouble(),
                          topPosition: math.Random().nextDouble(),
                        );
                      }),
                      
                      // Center Glow
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.2),
                              blurRadius: 40,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),

                      // Animated Broken Heart SVG replacement
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Left piece
                              Transform.translate(
                                offset: Offset(-_slideAnimation.value, 0),
                                child: Transform.rotate(
                                  angle: -_slideAnimation.value * math.pi / 180,
                                  child: CustomPaint(
                                    size: const Size(100, 100),
                                    painter: _BrokenHeartLeftPainter(),
                                  ),
                                ),
                              ),
                              // Right piece
                              Transform.translate(
                                offset: Offset(_slideAnimation.value, 0),
                                child: Transform.rotate(
                                  angle: _slideAnimation.value * math.pi / 180,
                                  child: CustomPaint(
                                    size: const Size(100, 100),
                                    painter: _BrokenHeartRightPainter(),
                                  ),
                                ),
                              ),
                              // Center Crack
                              CustomPaint(
                                size: const Size(100, 100),
                                painter: _BrokenHeartCrackPainter(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // X icon circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.red.shade600, size: 28, weight: 800),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    const Text(
                      '¡Oh, no!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937), // gray-800
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle / Explanation
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                          fontFamily: 'Outfit',
                        ),
                        children: [
                          const TextSpan(text: 'La respuesta correcta era:\n'),
                          TextSpan(
                            text: widget.correctAnswer,
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const TextSpan(text: '\n¡No te preocupes, cada error es una oportunidad para aprender!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Contenedor de Vidas Restantes
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Te quedan ${widget.remainingHearts} vidas',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 3D Button
                    _Button3DRed(
                      text: 'Entendido',
                      onPressed: widget.onNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final int delay;
  final double leftPosition;
  final double topPosition;

  const _FloatingParticle({required this.delay, required this.leftPosition, required this.topPosition});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.leftPosition * 300, // Approx width
      top: widget.topPosition * 150,   // Approx height
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          );
        },
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red.shade200.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Button3DRed extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _Button3DRed({required this.text, required this.onPressed});

  @override
  State<_Button3DRed> createState() => _Button3DRedState();
}

class _Button3DRedState extends State<_Button3DRed> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 4 : 0),
        padding: EdgeInsets.only(bottom: _isPressed ? 0 : 4),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrokenHeartLeftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
      
    final originalPath = Path()
      ..moveTo(12, 21.35)
      ..lineTo(10.55, 20.03)
      ..cubicTo(5.4, 15.36, 2, 12.27, 2, 8.5)
      ..cubicTo(2, 5.41, 4.41, 3, 7.5, 3)
      ..cubicTo(8.8, 3, 10.05, 3.55, 11, 4.5)
      ..lineTo(12, 12)
      ..lineTo(10, 13)
      ..lineTo(12, 15)
      ..lineTo(11, 18)
      ..lineTo(12, 21.35)
      ..close();
      
    final matrix = Matrix4.identity()..scale(100/24, 100/24);
    canvas.drawPath(originalPath.transform(matrix.storage), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrokenHeartRightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;
      
    final originalPath = Path()
      ..moveTo(12, 21.35)
      ..lineTo(13.45, 20.03)
      ..cubicTo(18.6, 15.36, 22, 12.27, 22, 8.5)
      ..cubicTo(22, 5.41, 19.59, 3, 16.5, 3)
      ..cubicTo(15.2, 3, 13.95, 3.55, 13, 4.5)
      ..lineTo(12, 12)
      ..lineTo(14, 13)
      ..lineTo(12, 15)
      ..lineTo(13, 18)
      ..lineTo(12, 21.35)
      ..close();
      
    final matrix = Matrix4.identity()..scale(100/24, 100/24);
    canvas.drawPath(originalPath.transform(matrix.storage), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrokenHeartCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final originalPath = Path()
      ..moveTo(12, 4.5)
      ..lineTo(13, 7)
      ..lineTo(11, 9)
      ..lineTo(13, 12)
      ..lineTo(11, 15)
      ..lineTo(13, 18)
      ..lineTo(12, 21.35);
      
    final matrix = Matrix4.identity()..scale(100/24, 100/24);
    canvas.drawPath(originalPath.transform(matrix.storage), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
