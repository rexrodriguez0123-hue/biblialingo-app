import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas exitosamente'),
            backgroundColor: Colors.green,
          ),
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
    final bool excludeFestivities = userState.preferences['exclude_festivities'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sección: Preferencias Teológicas
          _buildSectionHeader('Preferencias Teológicas'),
          Card(
            child: ListTile(
              title: const Text('Excluir Festividades'),
              subtitle: const Text(
                'Excluye contenido de festividades seculares (ej. Halloween, Navidad) en ejercicios y lecciones',
              ),
              trailing: _isUpdatingPreferences
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: excludeFestivities,
                      onChanged: (v) =>
                          _updateTheologicalPreference(v, 'exclude_festivities'),
                    ),
            ),
          ),
          const SizedBox(height: 30),

          // Sección: Información de la App
          _buildSectionHeader('Acerca de camino_biblico'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Versión'),
                  subtitle: const Text('1.0.0+1'),
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Contenido Bíblico'),
                  subtitle: const Text('Reina-Valera 1960 (RVR1960)'),
                ),
                const Divider(height: 0),
                ListTile(
                  title: const Text('Estado del Contenido'),
                  subtitle: const Text('Génesis completo - Más libros próximamente'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Sección: Privacidad & Datos
          _buildSectionHeader('Privacidad'),
          Card(
            child: ListTile(
              title: const Text('Tu Información'),
              subtitle: const Text('Tus datos de progreso se guardan localmente y en nuestros servidores encriptados'),
              onTap: () => _showInfoDialog(
                'Privacidad de Datos',
                'camino_biblico respeta tu privacidad. Tu progreso de aprendizaje, preferencias teológicas y estadísticas se guardan de forma segura. No compartimos datos con terceros.',
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Sección: Soporte
          _buildSectionHeader('Soporte'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Preguntas Frecuentes'),
                  onTap: () => _showInfoDialog(
                    'FAQ',
                    '¿Cómo funciona la racha? Tu racha aumenta cada día que practicas al menos una lección.\n\n¿Qué pasa si pierdo mi racha? Puedes recuperarla si practicas nuevamente mañana.\n\n¿Cómo gano gemas? Completa lecciones correctamente para ganar gemas.',
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Contactar Soporte'),
                  subtitle: const Text('camino_biblico@example.com'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Copiar email: camino_biblico@example.com'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Sección: Cuenta
          _buildSectionHeader('Cuenta'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutConfirmation(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final api = context.read<ApiService>();
              api.setToken(null);
              context.read<UserState>().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}


