import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mi Rendimiento', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumen semanal', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // Gráfico Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1F0533).withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1F0533).withOpacity(0.1)),
              ),
              child: const Center(
                child: Icon(Icons.bar_chart, size: 80, color: Color(0xFF1F0533)),
              ),
            ),

            const SizedBox(height: 32),
            const Text('Métricas clave', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Grid de métricas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard('Clicks', '1,240', Icons.ads_click, Colors.blue),
                _buildMetricCard('Alcance', '45k', Icons.groups, Colors.purple),
                _buildMetricCard('CTR', '3.2%', Icons.percent, Colors.orange),
                _buildMetricCard('Conversión', '12', Icons.shopping_bag, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}