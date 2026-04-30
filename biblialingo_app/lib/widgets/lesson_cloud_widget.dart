import 'package:flutter/material.dart';
import '../painters/cloud_progress_painter.dart';

class LessonCloudWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final bool isUnlocked;
  final bool isCloudOnLeft;
  final VoidCallback? onTap;

  const LessonCloudWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isUnlocked,
    required this.isCloudOnLeft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Canvas rectangular para que el path de nube se vea correcto
    final double cloudW = isUnlocked ? 140.0 : 100.0;
    final double cloudH = isUnlocked ? 88.0 : 63.0;

    // Si la lección está al 100%, mostrar trofeo
    final bool isCompleted = progress >= 1.0;
    final IconData displayIcon = isCompleted ? Icons.emoji_events : (isUnlocked ? icon : Icons.lock);

    // Colores: completada = amarillo, desbloqueada = blanco, bloqueada = gris
    final Color fillColor = isCompleted
        ? Colors.amber.shade200
        : (isUnlocked ? Colors.white : Colors.grey.shade200);
    final Color strokeColor = const Color(0xFF01579B);
    final Color iconColor = isCompleted
        ? Colors.amber.shade700
        : (isUnlocked ? const Color(0xFF0277BD) : Colors.grey.shade500);

    final cloudWidget = SizedBox(
      width: cloudW,
      height: cloudH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Relleno + sombra
          Positioned.fill(
            child: CustomPaint(
              painter: CloudFillPainter(
                fillColor: fillColor,
                isLocked: !isUnlocked,
              ),
            ),
          ),
          // 2. Trazo de progreso (solo si desbloqueada y tiene progreso)
          if (isUnlocked && progress > 0)
            Positioned.fill(
              child: CustomPaint(
                painter: CloudProgressPainter(
                  progress: progress,
                  strokeColor: strokeColor,
                  strokeWidth: 5.5,
                ),
              ),
            ),
          // 3. Ícono centrado
          Icon(
            displayIcon,
            size: cloudH * 0.40,
            color: iconColor,
          ),
        ],
      ),
    );

    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isCloudOnLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          textAlign: isCloudOnLeft ? TextAlign.left : TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: isCloudOnLeft ? TextAlign.left : TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: isUnlocked ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: isCloudOnLeft
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  cloudWidget,
                  const SizedBox(width: 16),
                  Expanded(child: textColumn),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textColumn),
                  const SizedBox(width: 16),
                  cloudWidget,
                ],
              ),
      ),
    );
  }
}
