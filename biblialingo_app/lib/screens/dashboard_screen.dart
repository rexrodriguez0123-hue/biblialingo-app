import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'practice_screen.dart';
import '../main.dart';
import 'dart:math' as math;
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _curriculumFuture;

  @override
  void initState() {
    super.initState();
    _loadCurriculum();
  }

  void _loadCurriculum() {
    _curriculumFuture = context.read<ApiService>().fetchCurriculum();
  }

  Future<void> _handleRefresh() async {
    setState(() => _loadCurriculum());
    try { await _curriculumFuture; } catch (_) {}
  }

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
            _buildTopStat(Icons.menu_book, 'RVR1960', Colors.grey.shade700),
            _buildTopStat(Icons.local_fire_department, '${userState.streak}', const Color(0xFF0277BD)),
            _buildTopStat(Icons.hexagon, '${userState.gems}', Colors.orange.shade800),
            const HeartTimerWidget(),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _curriculumFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Sin Conexión',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No pudimos cargar tu progreso. Revisa tu internet e inténtalo de nuevo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _loadCurriculum()),
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0277BD),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
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
            color: isUnlocked ? const Color(0xFF0277BD) : Colors.grey.shade600,
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

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF0277BD),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: children,
            ),
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
                color: const Color(0xFF0277BD),
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
            onTap: () {
               if (!isUnlocked) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: const Row(
                       children: [
                         Icon(Icons.lock, color: Colors.white, size: 20),
                         SizedBox(width: 10),
                         Expanded(child: Text('Completa las lecciones anteriores para desbloquear.', style: TextStyle(fontWeight: FontWeight.bold))),
                       ],
                     ),
                     backgroundColor: Colors.grey.shade800,
                     behavior: SnackBarBehavior.floating,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                     duration: const Duration(seconds: 3),
                   ),
                 );
                 return;
               }
               final userState = context.read<UserState>();
               if (userState.hearts <= 0) {
                 _showNoHeartsDialog(context);
                 return;
               }
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (_) => PracticeScreen(lessonId: lessonId))
               );
            },
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
                        isUnlocked ? const Color(0xFFBCE6FA) : Colors.grey.shade400
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
                          isGold ? Colors.orange : const Color(0xFF0277BD)
                        ),
                      ),
                    ),
                  // Botón circular central
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isUnlocked 
                        ? (isGold ? const Color(0xFFFFD700) : const Color(0xFF0277BD)) 
                        : Colors.grey.shade600,
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
                    color: isUnlocked ? Colors.black87 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
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
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color, 
            fontWeight: FontWeight.bold,
            fontSize: 18,
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

class HeartTimerWidget extends StatefulWidget {
  const HeartTimerWidget({super.key});

  @override
  State<HeartTimerWidget> createState() => _HeartTimerWidgetState();
}

class _HeartTimerWidgetState extends State<HeartTimerWidget> {
  Timer? _timer;
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final userState = context.read<UserState>();
      
      if (userState.hearts >= 5) {
        if (_timeString.isNotEmpty) {
          setState(() => _timeString = "");
        }
        return;
      }
      
      if (userState.lastHeartRegen == null) {
        if (_timeString != "Esperando servidor...") {
          setState(() => _timeString = "Esperando servidor...");
        }
        return;
      }

      DateTime? lastRegen = DateTime.tryParse(userState.lastHeartRegen!);
      if (lastRegen == null) {
        if (_timeString != "Error de fecha") {
          setState(() => _timeString = "Error de fecha");
        }
        return;
      }
      
      DateTime nextRegen = lastRegen.toUtc().add(const Duration(hours: 4));
      Duration remaining = nextRegen.difference(DateTime.now().toUtc());

      if (remaining.isNegative) {
        userState.updateStats(
          hearts: userState.hearts + 1, 
          lastHeartRegen: nextRegen.toUtc().toIso8601String()
        );
        return;
      }

      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String newTimeString = "(${twoDigits(remaining.inHours)}:${twoDigits(remaining.inMinutes.remainder(60))}:${twoDigits(remaining.inSeconds.remainder(60))})";
      
      if (_timeString != newTimeString) {
        setState(() {
          _timeString = newTimeString;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 26),
            const SizedBox(width: 6),
            Text(
              '${userState.hearts}/5',
              style: const TextStyle(
                color: Colors.red, 
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        if (userState.hearts < 5 && _timeString.isNotEmpty)
          Text(
            _timeString,
            style: const TextStyle(
              color: Color(0xFF00C853), // Green
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
