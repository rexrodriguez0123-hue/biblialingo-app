import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../painters/cloud_progress_painter.dart';

/// Widget que renderiza una lección como una nube con progreso
class LessonCloudWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final double cloudSize;
  final int lessonIndex;

  const LessonCloudWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isUnlocked,
    this.onTap,
    this.cloudSize = 140.0,
    this.lessonIndex = 0,
  });

  // Selecciona el estilo de nube (1, 2, o 3) basado en el índice
  String _getCloudStyle() {
    final styleIndex = (lessonIndex % 3) + 1;
    return 'assets/images/clouds/cloud_style_$styleIndex.svg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stack: Anillo de progreso + SVG nube + Ícono
          Stack(
            alignment: Alignment.center,
            children: [
              // Anillo de progreso (CustomPaint)
              CustomPaint(
                size: Size(cloudSize + 20, cloudSize + 20),
                painter: CloudProgressPainter(
                  progress: isUnlocked ? progress : 1.0,
                  isUnlocked: isUnlocked,
                  strokeWidth: 8.0,
                  progressColor: const Color(0xFFFF9800), // Naranja
                  backgroundColor: const Color(0xFF0277BD), // Azul
                ),
              ),
              // Nube SVG con fondo de color
              Container(
                width: cloudSize,
                height: cloudSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cloudSize / 2),
                ),
                child: Opacity(
                  opacity: isUnlocked ? 1.0 : 0.7,
                  child: SvgPicture.asset(
                    _getCloudStyle(),
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      isUnlocked
                          ? const Color(0xFF0277BD)
                          : const Color(0xFFCCCCCC),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              // Ícono encima de la nube
              Icon(
                icon,
                size: cloudSize * 0.5,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Título
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          // Subtítulo
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? Colors.grey : Colors.grey[500],
            ),
          ),
          // Mostrar progreso en porcentaje si está desbloqueado
          if (isUnlocked && progress > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF9800),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
