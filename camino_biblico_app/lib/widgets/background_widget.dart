import 'package:flutter/material.dart';

/// Widget que renderiza el fondo con PNG de nubes
class RobustBackgroundWallpaper extends StatelessWidget {
  const RobustBackgroundWallpaper({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFB0D9E8),
        ),
        child: Image.asset(
          'assets/images/clouds_wallpaper.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback a gradiente si falla la imagen
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F4F8),
                    Color(0xFFD9ECFF),
                    Color(0xFFC8E1F5),
                    Color(0xFFB0D4ED),
                    Color(0xFF95C8E5),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


