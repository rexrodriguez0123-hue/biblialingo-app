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
  bool _isUpdatingPreferences = false;

  Future<void> _updateTheologicalPreference(bool value, String key) async {
    setState(() => _isUpdatingPreferences = true);
    final api = context.read<ApiService>();
    final userState = context.read<UserState>();

    try {
      final currentPrefs = Map<String, dynamic>.from(userState.preferences);
      currentPrefs[key] = value;

      final result = await api.patchProfile({
        'theological_preferences': currentPrefs
      });

      if (mounted) {
        userState.updateStats(
          preferences: result['user']['profile']['theological_preferences']
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPreferences = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();
    
    // Parse preference safely
    final bool excludeFestivities = userState.preferences['exclude_festivities'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings logic placeholder
            },
          ),
        ],
      ),
      body: Padding(
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
            ListTile(
              title: const Text('Preferencias Teológicas'),
              subtitle: const Text('Excluir festividades (ej. Halloween/Navidad en oraciones)'),
              trailing: _isUpdatingPreferences 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Switch(
                      value: excludeFestivities, 
                      onChanged: (v) => _updateTheologicalPreference(v, 'exclude_festivities'),
                    ),
            ),
            const Spacer(),
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
