import 'package:flutter/material.dart';
import 'package:inklop_v1/core/services/secure_storage_service.dart';
import 'package:inklop_v1/features/auth/presentation/screens/welcome_screen.dart';
import 'package:inklop_v1/features/profile/presentation/screens/linked_accounts_screen.dart';
import 'package:inklop_v1/features/profile/presentation/screens/support_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String accessToken;
  const SettingsScreen({super.key, required this.accessToken});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificaciones = true;
  bool _notificacionesEmail = true;
  final _storageService = SecureStorageService();

  // 🚀 Lógica de cierre de sesión completa
  Future<void> _logout() async {
    // Borramos todos los tokens (Access y Refresh)
    await _storageService.deleteAll();

    if (mounted) {
      // Limpiamos el historial de pantallas y vamos al Welcome
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    }
  }

  // 🚀 Diálogo estilo "Inklop" (idéntico a tu referencia)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¿Estás seguro que deseas cerrar sesión?\nTendrás que volver a ingresar tus credenciales para usar Inklop.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E5EA)),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Cerrar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              children: [
                _sectionLabel('Cuenta'),
                _navTile(
                  assetIcon: 'assets/images/ic_candado.png',
                  title: 'Seguridad',
                  onTap: () {},
                ),
                _navTile(
                  assetIcon: 'assets/images/icon-park-outline_connect.png',
                  title: 'Cuentas Vinculadas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      // 💡 IMPORTANTE: Verifica que LinkedAccountsScreen reciba un String
                      builder: (_) => LinkedAccountsScreen(
                          accessToken: widget.accessToken),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionLabel('Notificaciones'),
                _switchTile(
                  assetIcon: 'assets/images/ic_campana.png',
                  title: 'Activar Notificaciones',
                  value: _notificaciones,
                  onChanged: (v) => setState(() => _notificaciones = v),
                ),
                _switchTile(
                  assetIcon: 'assets/images/ic_email_conf.png',
                  title: 'Activar Notificaciones por e-mail',
                  value: _notificacionesEmail,
                  onChanged: (v) => setState(() => _notificacionesEmail = v),
                ),
                const SizedBox(height: 24),
                _sectionLabel('Otros'),
                _navTile(
                  assetIcon: 'assets/images/ic_llave.png',
                  title: 'Ayuda y soporte',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _sectionLabel('Sesión'),
                _navTile(
                  assetIcon: 'assets/images/ic_logout.png',
                  title: 'Cerrar sesión',
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: _showLogoutDialog,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS UI ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 8, right: 24, bottom: 22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6B1FA8), Color(0xFF3D0D6B), Color(0xFF0D0018)],
          stops: [0.0, 0.45, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              margin: const EdgeInsets.only(left: 8, right: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/ic_back_arrow.png',
                  width: 20, height: 20, color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Configuración',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _navTile({
    required String assetIcon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.black,
    Color iconColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Image.asset(assetIcon, width: 20, height: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: textColor == Colors.redAccent ? Colors.redAccent.withOpacity(0.3) : const Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required String assetIcon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Image.asset(assetIcon, width: 20, height: 20, color: Colors.black),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, color: Colors.black)),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF6B1FA8),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE5E5EA),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}