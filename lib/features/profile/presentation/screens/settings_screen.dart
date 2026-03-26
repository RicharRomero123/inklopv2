import 'package:flutter/material.dart';
import 'package:inklop_v1/features/profile/presentation/screens/linked_accounts_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String accessToken;
  const SettingsScreen({super.key, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Morado (Imagen 4e12db)
          _buildHeader(context, 'Configuración'),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildTile(Icons.lock_outline, 'Seguridad', () {}),
                _buildTile(Icons.hub_outlined, 'Cuentas Vinculadas', () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LinkedAccountsScreen(accessToken: accessToken)
                  ));
                }),
                const SizedBox(height: 24),
                const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildSwitchTile('Activar Notificaciones'),
                _buildSwitchTile('Notificaciones por e-mail'),
                const SizedBox(height: 24),
                const Text('Otros', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildTile(Icons.build_outlined, 'Ayuda y soporte', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, bottom: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1F0533), Color(0xFF0D0214)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title) {
    return SwitchListTile(
      title: Text(title),
      value: true,
      onChanged: (v) {},
      activeColor: const Color(0xFF1F0533),
    );
  }
}