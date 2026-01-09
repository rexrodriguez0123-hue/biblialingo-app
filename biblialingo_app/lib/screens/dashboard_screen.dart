import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTopStat(Icons.flag, 'RVR1960', Colors.grey),
            _buildTopStat(Icons.local_fire_department, '${user?['streak'] ?? 0}', Colors.orange),
            _buildTopStat(Icons.diamond, '${user?['gems'] ?? 0}', Colors.blue),
            _buildTopStat(Icons.favorite, '${user?['hearts'] ?? 5}', Colors.red),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildUnitHeader('UNIDAD 1: Los Orígenes', Colors.blue),
          const SizedBox(height: 20),
          _buildPathNode(context, 'La Creación', '(Gén 1-2)', Icons.public, Colors.cyan, true),
          _buildPathConnector(),
          _buildPathNode(context, 'El Edén', '(Gén 2-3)', Icons.park, Colors.cyan, true),
          _buildPathConnector(),
          _buildPathNode(context, 'El Diluvio', '(Gén 6-9)', Icons.lock, Colors.grey, false),
          _buildPathConnector(),
          _buildPathNode(context, 'Introducción', 'RVR1960', Icons.emoji_events, Colors.amber, true, isGold: true),
        ],
      ),
    );
  }

  Widget _buildTopStat(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUnitHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      color: color,
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPathNode(BuildContext context, String title, String subtitle, IconData icon, Color color, bool isUnlocked, {bool isGold = false}) {
    return GestureDetector(
      onTap: isUnlocked ? () => Navigator.pushNamed(context, '/practice') : null,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isUnlocked ? (isGold ? Colors.amber : color) : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPathConnector() {
    return SizedBox(
      height: 40,
      child: Center(
        child: Container(
          width: 4,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}
