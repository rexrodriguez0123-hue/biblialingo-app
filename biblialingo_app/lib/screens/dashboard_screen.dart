import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../services/api_service.dart';
import 'practice_screen.dart';
import '../main.dart';
import '../widgets/lesson_cloud_widget.dart';
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
          
          // Invertir orden para que la lección 1 aparezca al bottom con reverse: true
          final reversedLessons = List.from(lessons.reversed);

          // Construir lista de nubes en zigzag con orden correcto
          List<Widget> children = [
            const SizedBox(height: 100), // Espacio inicial para el scroll
            // UNIDAD como StickyHeader
            StickyHeader(
              header: _buildUnitRibbon('UNIDAD 1: Los Orígenes'),
              content: Column(
                children: [
                  const SizedBox(height: 30),
                  // Lecciones en orden reverso (para que con reverse: true, aparezcan correctamente)
                  for (int i = 0; i < reversedLessons.length; i++)
                    _buildLessonWidget(reversedLessons[i], i, reversedLessons.length),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ];

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF0277BD),
            child: ListView(
              reverse: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 20, bottom: 0),
              children: children,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonWidget(Map<String, dynamic> lesson, int index, int totalLessons) {
    bool isUnlocked = lesson['is_unlocked'] ?? false;
    double progress = lesson['progress'] ?? 0.0;
    
    // Zigzag: índices pares van a 0.2, impares van a 0.6
    double alignment = (index % 2 == 0) ? 0.2 : 0.6;

    return Padding(
      padding: EdgeInsets.only(
        left: alignment * 80.0,
        top: 30.0,
        bottom: 30.0,
      ),
      child: LessonCloudWidget(
        title: lesson['title'],
        subtitle: 'Lección ${lesson['order']}',
        icon: _getIconForLesson(lesson['title']),
        progress: progress,
        isUnlocked: isUnlocked,
        lessonIndex: index,
        onTap: () {
          if (!isUnlocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Completa las lecciones anteriores para desbloquear.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.grey.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
            MaterialPageRoute(
              builder: (_) => PracticeScreen(lessonId: lesson['id']),
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
              left: 0,
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
              top: 42,
              left: 28,
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
              margin: const EdgeInsets.symmetric(horizontal: 25),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0277BD),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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

  @override
  void dispose() {
    super.dispose();
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
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(10, size.height / 2);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      // Ala derecha
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - 10, size.height / 2);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
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
    var paint = Paint()..color = const Color(0xFF155A8A);
    var path = Path();
    
    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
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
              color: Color(0xFF00C853),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
