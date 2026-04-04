import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // 🚀 Funciones para abrir los enlaces
  Future<void> _launchEmail() async {
    final Uri url = Uri.parse('mailto:soporte@inklop.com');
    if (!await launchUrl(url)) throw 'No se pudo abrir el email';
  }

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:+51927555467');
    if (!await launchUrl(url)) throw 'No se pudo abrir el teléfono';
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/51927555467');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir WhatsApp';
    }
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
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Medios de Contacto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 20),

                _buildContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email de Soporte',
                  subtitle: 'Respuesta en 24 horas',
                  info: 'soporte@inklop.com',
                  onTap: _launchEmail,
                ),

                _buildContactCard(
                  icon: Icons.phone_outlined,
                  title: 'Soporte Telefónico',
                  subtitle: 'Lunes a Viernes 9am - 6pm',
                  info: '+51 927 555 467',
                  onTap: _launchPhone,
                ),

                _buildContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'WhatsApp',
                  subtitle: 'Respuesta Inmediata',
                  info: '+51 927 555 467',
                  onTap: _launchWhatsApp,
                  isWhatsApp: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER (Igual a Settings/Profile para consistencia) ─────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14,
        left: 8,
        right: 24,
        bottom: 22,
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
              margin: const EdgeInsets.only(left: 8, right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const Text(
            'Soporte',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── CARD DE CONTACTO (Diseño image_4bef33.png) ─────────────────────────────
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String info,
    required VoidCallback onTap,
    bool isWhatsApp = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF2F2F7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo sutil
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: isWhatsApp ? Colors.purple : Colors.black, size: 22),
              ),
              const SizedBox(width: 16),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(info, style: const TextStyle(color: Color(0xFF1C1C1E), fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}