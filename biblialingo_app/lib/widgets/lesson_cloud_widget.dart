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
  final int lessonIndex;

  const LessonCloudWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isUnlocked,
    required this.isCloudOnLeft,
    this.onTap,
    this.lessonIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Nubes desbloqueadas más grandes, bloqueadas más pequeñas
    final double cloudSize = isUnlocked ? 118.0 : 88.0;
    final IconData displayIcon = isUnlocked ? icon : Icons.lock;

    // Colores: desbloqueada = azul sólido con ícono blanco
    //          bloqueada   = blanca con contorno gris y ícono gris
    final Color fillColor =
        isUnlocked ? const Color(0xFF0277BD) : Colors.white;
    final Color strokeColor =
        isUnlocked ? const Color(0xFF01579B) : const Color(0xFFB0BEC5);
    final Color iconColor =
        isUnlocked ? Colors.white : const Color(0xFF90A4AE);

    final cloudWidget = SizedBox(
      width: cloudSize,
      height: cloudSize,
      child: Stack(
        // Alinear el ícono ligeramente hacia abajo, en el cuerpo de la nube
        alignment: const Alignment(0, 0.25),
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CloudProgressPainter(
                progress: isUnlocked ? progress : 0.0,
                isUnlocked: isUnlocked,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: isUnlocked ? 5.5 : 4.0,
              ),
            ),
          ),
          Icon(
            displayIcon,
            size: cloudSize * 0.35,
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
