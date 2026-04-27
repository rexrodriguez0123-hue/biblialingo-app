import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'practice_screen.dart';
import '../main.dart';
import 'dart:math' as math;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    return Scaffold(
      backgroundColor: const Color(0xFFE5F7FF), // Fondo celeste muy claro
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTopStat(Icons.menu_book, 'RVR1960', Colors.grey),
            _buildTopStat(Icons.local_fire_department, '${userState.streak}', Colors.blue),
            _buildTopStat(Icons.hexagon, '${userState.gems}', Colors.orange),
            _buildTopStat(Icons.favorite, '${userState.hearts}/5', Colors.red),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: context.read<ApiService>().fetchCurriculum(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             // Fallback to offline/dummy data if error, or show error
            return Center(child: Text('Error cargando curso: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final lessons = data['lessons'] as List<dynamic>? ?? [];
          final currentUnits = lessons; // For now assuming 1 course = flat list or grouped

          // Construimos la lista de nodos dinámicamente
          List<Widget> children = [
             _buildUnitRibbon('UNIDAD 1: Los Orígenes'),
             const SizedBox(height: 30),
          ];

          for (int i = 0; i < currentUnits.length; i++) {
            final lesson = currentUnits[i];
            // Determine alignment and connector
            // Simple zig-zag pattern: 0.2 -> 0.6 -> 0.2 -> 0.6
            double align = (i % 2 == 0) ? 0.2 : 0.6; 
            
            bool isLast = i == currentUnits.length - 1;
            
            // Determine locked status (based on previous completion)
            // This logic should ideally come from backend 'is_locked' flag
            bool isUnlocked = lesson['is_unlocked'] ?? false;
            
            children.add(_buildPathNode(
              context: context,
              lessonId: lesson['id'],
              title: lesson['title'],
              subtitle: 'Lección ${lesson['order']}', // Or fetch verse range
              icon: _getIconForLesson(lesson['title']),
              color: isUnlocked ? const Color(0xFF4AC3F5) : Colors.grey.shade400,
              alignment: align,
              isUnlocked: isUnlocked,
              progress: lesson['progress'] ?? 0.0,
            ));

            if (!isLast) {
               double nextAlign = ((i + 1) % 2 == 0) ? 0.2 : 0.6;
               children.add(_buildWavyConnector(startAlign: align, endAlign: nextAlign));
            }
          }
          
          children.add(const SizedBox(height: 50));

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: children,
          );
        },
      ),
    );
  }

  IconData _getIconForLesson(String title) {
    if (title.toLowerCase().contains('creación')) return Icons.public;
    if (title.toLowerCase().contains('edén')) return Icons.park;
    if (title.toLowerCase().contains('diluvio')) return Icons.water_drop;
    if (title.toLowerCase().contains('intro')) return Icons.menu_book;
    return Icons.star;
  }

  void _showNoHeartsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Sin Corazones! 💔'),
        content: const Text('Te has quedado sin vidas. Espera a que se regeneren o ve a la tienda para rellenarlas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/shop');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Ir a la Tienda', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  Widget _buildUnitRibbon(String title) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Alitas del listón (Ribbon Ends)
            Positioned(
              top: 12,
              left: 0, // Se salen un poco más
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ala Izquierda
                  CustomPaint(
                    painter: _RibbonBackPainter(isLeft: true, color: const Color(0xFF2389C7)),
                    size: const Size(40, 40),
                  ),
                  // Ala Derecha
                  CustomPaint(
                    painter: _RibbonBackPainter(isLeft: false, color: const Color(0xFF2389C7)),
                    size: const Size(40, 40),
                  ),
                ],
              ),
            ),
            
            // Triángulos de sombra (Fold Shadows) para dar profundidad
            Positioned(
              top: 42, // Justo debajo del borde main
              left: 28, // Ajustado al borde del main container
              child: CustomPaint(
                painter: _RibbonShadowPainter(isLeft: true),
                size: const Size(12, 12),
              ),
            ),
            Positioned(
              top: 42,
              right: 28,
              child: CustomPaint(
                painter: _RibbonShadowPainter(isLeft: false),
                size: const Size(12, 12),
              ),
            ),

            // Contenedor Principal (Main Banner)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25), // Deja espacio para las alas
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4AC3F5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 2,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep existing methods) ...
  
  // Reuse existing node/connector methods...
  Widget _buildPathNode({
    required BuildContext context,
    required int lessonId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double alignment,
    required bool isUnlocked,
    double progress = 0.0,
    bool isGold = false,
  }) {
    // Calcular el margen izquierdo basado en la alineación (0.0 a 1.0)
    // Centramos el contenido en una columna imaginaria
    final double leftPadding = 30.0 + (alignment * 80.0);

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: isUnlocked ? () {
               final userState = context.read<UserState>();
               if (userState.hearts <= 0) {
                 _showNoHeartsDialog(context);
                 return;
               }
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (_) => PracticeScreen(lessonId: lessonId))
               );
            } : null,
            child: SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo de fondo (Track)
                  SizedBox(
                    width: 85,
                    height: 85,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isUnlocked ? const Color(0xFFBCE6FA) : Colors.grey.shade300
                      ),
                    ),
                  ),
                  // Anillo de progreso (Progress)
                  if (isUnlocked && progress > 0)
                    SizedBox(
                      width: 85,
                      height: 85,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isGold ? Colors.orange : const Color(0xFF4AC3F5)
                        ),
                      ),
                    ),
                  // Botón circular central
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isUnlocked 
                        ? (isGold ? const Color(0xFFFFD700) : const Color(0xFF4AC3F5)) 
                        : Colors.grey.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 0,
                          offset: const Offset(0, 5)
                        )
                      ],
                    ),
                    child: Icon(
                      isGold ? Icons.emoji_events : icon,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Etiquetas de Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isUnlocked ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWavyConnector({required double startAlign, required double endAlign}) {
    return Container(
      height: 50,
      width: double.infinity,
      child: CustomPaint(
        painter: _BezierConnectorPainter(startAlign: startAlign, endAlign: endAlign),
      ),
    );
  }

  Widget _buildTopStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// Pintor para las alas del listón (V-Cut)
class _RibbonBackPainter extends CustomPainter {
  final bool isLeft;
  final Color color;
  _RibbonBackPainter({required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    
    if (isLeft) {
      // Ala izquierda
      path.moveTo(size.width, 0); // Top Right
      path.lineTo(0, 0); // Top Left
      path.lineTo(10, size.height / 2); // V-Cut center
      path.lineTo(0, size.height); // Bottom Left
      path.lineTo(size.width, size.height); // Bottom Right
    } else {
      // Ala derecha
      path.moveTo(0, 0); // Top Left
      path.lineTo(size.width, 0); // Top Right
      path.lineTo(size.width - 10, size.height / 2); // V-Cut center
      path.lineTo(size.width, size.height); // Bottom Right
      path.lineTo(0, size.height); // Bottom Left
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Pintor para las sombras triangulares
class _RibbonShadowPainter extends CustomPainter {
  final bool isLeft;
  _RibbonShadowPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = const Color(0xFF155A8A); // Sombra más oscura
    var path = Path();
    
    // Dibujamos un triángulo pegado a la esquina inferior del main container
    if (isLeft) {
      path.moveTo(size.width, 0); // Top Right (corner of main)
      path.lineTo(0, 0); // Top Left (start of wing)
      path.lineTo(size.width, size.height); // Bottom Right
    } else {
      path.moveTo(0, 0); 
      path.lineTo(size.width, 0); 
      path.lineTo(0, size.height); 
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// Pintor para las curvas suaves (S-Curves)
class _BezierConnectorPainter extends CustomPainter {
  final double startAlign;
  final double endAlign;

  _BezierConnectorPainter({required this.startAlign, required this.endAlign});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFBCE6FA) // Celeste claro del track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    var path = Path();
    
    // Cálculo exacto del centro de los nodos basado en la fórmula de padding:
    // leftPadding = 30.0 + (alignment * 80.0);
    // Ancho del nodo = 90.0
    // Centro del NODO = leftPadding + (90 / 2) = 30 + (align * 80) + 45 = 75 + (align * 80)
    
    final double startX = 75.0 + (startAlign * 80.0);
    final double endX = 75.0 + (endAlign * 80.0);
    
    path.moveTo(startX, 0);
    
    // Curva cúbica para una "S" suave y perfecta
    // Usamos control points verticales para asegurar que la línea salga recta hacia abajo
    path.cubicTo(
      startX, size.height * 0.5, // Control 1: Baja verticalmente desde el inicio
      endX, size.height * 0.5,   // Control 2: Sube verticalmente desde el fin (o baja hacia el fin)
      endX, size.height          // Destino
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
