import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameOverPopup extends StatefulWidget {
  final int correctCount;
  final int totalAttempted;
  final int gemsEarned;
  final VoidCallback onNext;

  const GameOverPopup({
    super.key,
    required this.correctCount,
    required this.totalAttempted,
    required this.gemsEarned,
    required this.onNext,
  });

  @override
  State<GameOverPopup> createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _popAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Pop animation for gems
    _popController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _scaleController.forward();
        _popController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.totalAttempted > 0
        ? ((widget.correctCount / widget.totalAttempted) * 100).toInt()
        : 0;
    final isExcellent = percentage >= 80;
    final isGood = percentage >= 60;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnimation,
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
              // Top Section (Header with gradient)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isExcellent
                          ? [Color(0xFF4CAF50), Color(0xFF45a049)]
                          : isGood
                              ? [Color(0xFF2196F3), Color(0xFF1976D2)]
                              : [Color(0xFFFF9800), Color(0xFFE65100)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isExcellent
                            ? '¡Excelente! 🌟'
                            : isGood
                                ? '¡Muy Bien! 👍'
                                : '¡Sigue Intentando! 💪',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Precisión: $percentage%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Stats Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Correctas', widget.correctCount.toString(), Colors.green),
                        _buildStatItem(
                          'Totales',
                          widget.totalAttempted.toString(),
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progreso de Lección',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isExcellent
                                  ? Colors.green
                                  : isGood
                                      ? Colors.blue
                                      : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Gems earned
                    if (widget.gemsEarned > 0)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '+ ${widget.gemsEarned} Gemas',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (_popAnimation.value > 0)
                            Transform.scale(
                              scale: 1 + (_popAnimation.value * 0.5),
                              child: Opacity(
                                opacity: 1 - _popAnimation.value,
                                child: const Text(
                                  '💎',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),

              // Bottom Section (Buttons)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isExcellent
                          ? Colors.green
                          : isGood
                              ? Colors.blue
                              : Colors.orange,
                    ),
                    child: const Text(
                      'Siguiente Lección',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
