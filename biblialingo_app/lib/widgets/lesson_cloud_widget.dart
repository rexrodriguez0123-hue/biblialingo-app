import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  String _getCloudStyle() {
    final styleIndex = (lessonIndex % 3) + 1;
    return 'assets/images/clouds/cloud_style_$styleIndex.svg';
  }

  @override
  Widget build(BuildContext context) {
    final double cloudSize = isUnlocked ? 115.0 : 85.0;
    final double ringSize = cloudSize + 16;
    final IconData displayIcon = isUnlocked ? icon : Icons.lock;

    final cloudStack = Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(ringSize, ringSize),
          painter: CloudProgressPainter(
            progress: isUnlocked ? progress : 1.0,
            isUnlocked: isUnlocked,
            strokeWidth: 7.0,
            progressColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFF0277BD),
          ),
        ),
        SizedBox(
          width: cloudSize,
          height: cloudSize,
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.75,
            child: SvgPicture.asset(
              _getCloudStyle(),
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                isUnlocked
                    ? const Color(0xFF0277BD)
                    : const Color(0xFFB0C4D8),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        Icon(
          displayIcon,
          size: cloudSize * 0.42,
          color: Colors.white,
        ),
      ],
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
                  cloudStack,
                  const SizedBox(width: 12),
                  Expanded(child: textColumn),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: textColumn),
                  const SizedBox(width: 12),
                  cloudStack,
                ],
              ),
      ),
    );
  }
}
