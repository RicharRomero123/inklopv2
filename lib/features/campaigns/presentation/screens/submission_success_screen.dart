import 'package:flutter/material.dart';

class SubmissionSuccessScreen extends StatelessWidget {
  final String campaignTitle;
  const SubmissionSuccessScreen({super.key, required this.campaignTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // 1. ÁREA DE CONTENIDO (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // ── ÍCONO CHECK (Grande y sin círculo) ──
                    _safeImage(
                      'assets/images/ic_check.png',
                      fallback: Icons.check_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 32),

                    // ── TÍTULOS CENTRADOS ──
                    const Text(
                      'Video Enviado Exitosamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      campaignTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── CARD: COBRAR MANUALMENTE ──
                    _infoCard(
                      iconPath: 'assets/images/ic_cash.png',
                      fallbackIcon: Icons.payments_outlined,
                      title: 'Debes cobrar manualmente',
                      body: 'Una vez que tu video sea aprobado y alcance el pago mínimo deberá entrar a los detalles y presionar "Cobrar".',
                    ),
                    const SizedBox(height: 16),

                    // ── CARD: ALERTA PRESUPUESTO ──
                    _infoCard(
                      iconPath: 'assets/images/ic_alert.png',
                      fallbackIcon: Icons.warning_amber_rounded,
                      title: 'Estate atento al presupuesto',
                      body: 'Si el presupuesto se agota antes que cobres, es posible que tu video no sea monetizado.',
                      isWarning: true,
                    ),
                    const SizedBox(height: 16),

                    // ── CARD: QUÉ SIGUE ──
                    _buildStepsCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 2. BOTÓN INFERIOR (Fijado abajo)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  // 🚀 Estilo oscuro como image_d84b83.png
                  gradient: const LinearGradient(
                    colors: [Color(0xFF262626), Color(0xFF121212)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🚀 Manejo seguro de imágenes
  Widget _safeImage(String path, {required IconData fallback, double size = 22, Color color = Colors.white}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(fallback, color: color, size: size),
    );
  }

  Widget _infoCard({
    required String iconPath,
    required IconData fallbackIcon,
    required String title,
    required String body,
    bool isWarning = false,
  }) {
    final color = isWarning ? const Color(0xFFFF453A) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? color.withOpacity(0.08) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _safeImage(iconPath, fallback: fallbackIcon, color: color, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: isWarning ? color.withOpacity(0.7) : Colors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _safeImage('assets/images/ic_detalles.png', fallback: Icons.list_alt, size: 20),
            const SizedBox(width: 10),
            const Text('¿Que sigue?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 16),
          _stepItem('1.', 'Se revisará y aprobará tu video'),
          _stepItem('2.', 'Tu video empezará a acumular visualizaciones'),
          _stepItem('3.', 'Al alcanzar el mínimo, podrás cobrar'),
          _stepItem('4.', 'Ve a "Mis envíos" y presiona "Cobrar"'),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}