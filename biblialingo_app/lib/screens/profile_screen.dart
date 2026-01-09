import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
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
              user?['username'] ?? 'Usuario',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Racha', '${user?['streak'] ?? 0} días'),
                _buildStatCard('Total XP', '1250'), // Placeholder XP
              ],
            ),
            const SizedBox(height: 40),
            ListTile(
              title: const Text('Preferencias Teológicas'),
              subtitle: const Text('Excluir festividades'),
              trailing: Switch(value: true, onChanged: (v) {}),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
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
