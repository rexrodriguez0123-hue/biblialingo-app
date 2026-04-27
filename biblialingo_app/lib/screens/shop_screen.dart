import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../main.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _isLoading = false;

  Future<void> _buyItem(String itemType, int cost, String name) async {
    final userState = context.read<UserState>();

    if (userState.gems < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes suficientes gemas para $name.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (itemType == 'refill_hearts' && userState.hearts >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tus corazones ya están llenos.'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = context.read<ApiService>();
      final result = await api.shopPurchase(itemType);

      if (mounted) {
        // Update user state with the result
        userState.updateStats(
          hearts: result['hearts'],
          gems: result['gems_remaining'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Compra exitosa! $name aplicado.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la compra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.hexagon, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${userState.gems}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Mejoras',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildShopItem(
                  context,
                  title: 'Rellenar Corazones',
                  description: 'Rellena tus corazones al máximo (5) inmediatamente.',
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  cost: 50,
                  onTap: () => _buyItem('refill_hearts', 50, 'Rellenar Corazones'),
                ),
                const SizedBox(height: 16),
                _buildShopItem(
                  context,
                  title: 'Streak Freeze',
                  description: 'Protege tu racha de días consecutivos si olvidas practicar un día.',
                  icon: Icons.ac_unit,
                  iconColor: Colors.blue,
                  cost: 100,
                  onTap: () => _buyItem('streak_freeze', 100, 'Streak Freeze'),
                ),
              ],
            ),
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required int cost,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                elevation: 0,
                side: const BorderSide(color: Colors.orange, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hexagon, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    cost.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
