import 'package:flutter/material.dart';
import 'package:inklop_v1/features/auth/presentation/screens/email_auth_screen.dart';
import '../../data/auth_service.dart';
import '../../data/user_api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import 'birth_date_screen.dart';
import '../../../main/presentation/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService();
  final UserApiService _userApiService = UserApiService();
  final SecureStorageService _storageService = SecureStorageService();

  bool _isLoading = false;

  // ── LÓGICA DE AUTENTICACIÓN SOCIAL ──────────────────────────────────────────
  Future<void> _handleSocialAuth(String connection) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);

    try {
      // 🚀 1. Llamamos al login social y obtenemos el mapa de resultados
      final result = await _authService.loginSocialWithDetails(connection);

      final String? token = result['token'];
      final String? refreshToken = result['refreshToken']; // 🚀 Capturamos el refresh
      final String? email = result['email'];

      if (token != null && email != null && mounted) {
        // 🚀 2. Verificamos si el perfil ya está registrado en el backend
        final isCompleted = await _userApiService.isProfileCompleted(token);

        if (isCompleted) {
          // ✅ 3. USUARIO COMPLETADO: Guardamos AMBOS tokens con el nuevo formato
          await _storageService.saveToken(
            access: token,
            refresh: refreshToken ?? '', // Enviamos vacío si no viene el refresh
          );

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(accessToken: token)),
                  (route) => false,
            );
          }
        } else {
          // 🚀 4. USUARIO NUEVO: Vamos al flujo de completar datos
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BirthDateScreen(accessToken: token, email: email),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAuthSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthBottomSheet(
        onGoogle: () => _handleSocialAuth('google-oauth2'),
        onApple: () => _handleSocialAuth('apple'),
        onEmail: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmailAuthScreen()),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.1,
            colors: [Color(0xFF2B1255), Color(0xFF0D021D)],
            stops: [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Hero Image
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/welcome_hero.png',
                  height: MediaQuery.of(context).size.height * 0.45,
                  fit: BoxFit.fitWidth,
                ),
              ),

              const Spacer(flex: 1),

              // Logo y Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo_inklop.png', height: 35),
                    const SizedBox(height: 10),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFF9D5CDA)],
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: const Text(
                        'Where Everyone\nWins_',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Botón Empezar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : FilledButton(
                    onPressed: _showAuthSheet,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Empezar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── BOTTOM SHEET Y COMPONENTES (Sin cambios de lógica) ───────────────────────
class _AuthBottomSheet extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onEmail;

  const _AuthBottomSheet({
    required this.onGoogle,
    required this.onApple,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, size: 22, color: Color(0xFF8E8E93)),
            ),
          ),
          const SizedBox(height: 8),
          Image.asset('assets/images/logo_inklop.png', height: 26, fit: BoxFit.contain),
          const SizedBox(height: 16),
          const Text(
            'Empieza Ahora',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1E)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Regístrate para empezar a monetizar tu creatividad o crear campañas y monitorear tu alcance',
            style: TextStyle(fontSize: 14, color: Color(0xFF8E8E93), height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: onEmail,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1C1C1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Continuar con Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SocialButton(iconPath: 'assets/images/ic_google.png', onTap: onGoogle)),
              const SizedBox(width: 12),
              Expanded(child: _SocialButton(iconPath: 'assets/images/ic_apple.png', onTap: onApple)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Al continuar aceptas nuestros Términos y Privacidad',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  const _SocialButton({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Image.asset(iconPath, height: 24, fit: BoxFit.contain)),
      ),
    );
  }
}