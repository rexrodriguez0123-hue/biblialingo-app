import 'package:flutter/material.dart';
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

  const LessonCloudWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.isUnlocked,
    this.onTap,
    this.cloudSize = 140.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nube con progreso
            Stack(
              alignment: Alignment.center,
              children: [
                // Trazo de progreso (círculo alrededor)
                CustomPaint(
                  size: Size(cloudSize + 20, cloudSize + 20),
                  painter: CloudProgressPainter(
                    progress: progress,
                    isUnlocked: isUnlocked,
                    strokeWidth: 6.0,
                    progressColor: const Color(0xFFFF9800), // Naranja
                    backgroundColor: const Color(0xFF0277BD), // Azul
                  ),
                ),
                // Nube (fondo)
                _CloudShape(
                  size: cloudSize,
                  color: isUnlocked
                      ? const Color(0xFF0277BD) // Azul desbloqueado
                      : const Color(0xFFCCCCCC), // Gris bloqueado
                ),
                // Icono dentro de la nube
                Icon(
                  icon,
                  size: cloudSize * 0.5,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Textos
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black87 : Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
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
      ),
    );
  }
}

/// Widget que dibuja la forma de nube como fondo
class _CloudShape extends StatelessWidget {
  final double size;
  final Color color;

  const _CloudShape({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.75,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.4),
      ),
      child: Stack(
        children: [
          // Crear efecto de nube con círculos superpuestos
          Positioned(
            left: size * 0.1,
            top: -size * 0.15,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * 0.1,
            top: -size * 0.1,
            child: Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -size * 0.1,
            top: size * 0.15,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
