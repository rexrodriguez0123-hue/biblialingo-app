import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  @override
  void initState() {
    super.initState();
    _checkAndSyncLevel();
  }

  Future<void> _checkAndSyncLevel() async {
    try {
      final api = context.read<ApiService>();
      await api.checkLevelUp(); // Notifica al backend de cualquier nivel nuevo
    } catch (e) {
      debugPrint('Sincronización de nivel fallida: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    // Cálculos del Sistema de Niveles
    final int totalXp = userState.totalXp;
    final int level = (totalXp / 100).floor() + 1; // 100 XP por nivel
    final int currentLevelXp = totalXp % 100;
    final double progress = currentLevelXp / 100.0;
    final int xpNeeded = 100 - currentLevelXp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              userState.username.isNotEmpty ? userState.username : 'Usuario',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (userState.email.isNotEmpty)
              Text(userState.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            
            // --- BARRA DE PROGRESO DE NIVEL ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nivel $level', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0277BD))),
                      Text('$currentLevelXp / 100 XP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: Colors.blue.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0277BD)),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Gana $xpNeeded XP más para subir al Nivel ${level + 1}!',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade800, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- FIN BARRA DE PROGRESO ---

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('🔥 Racha', '${userState.streak} días'),
                _buildStatCard('⭐ Total XP', '${userState.totalXp}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('❤️ Corazones', '${userState.hearts}'),
                _buildStatCard('💎 Gemas', '${userState.gems}'),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final api = context.read<ApiService>();
                api.setToken(null);
                context.read<UserState>().logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
