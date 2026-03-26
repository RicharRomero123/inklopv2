import 'package:flutter/material.dart';
import 'package:inklop_v1/features/auth/presentation/screens/email_auth_screen.dart';
import '../../data/auth_service.dart';
import '../../data/user_api_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../widgets/social_button.dart';
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

  Future<void> _handleSocialAuth(String connection) async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.loginSocialWithDetails(connection);

      final token = result['token'];
      final email = result['email'];

      if (token != null && email != null && mounted) {
        final isCompleted = await _userApiService.isProfileCompleted(token);

        if (isCompleted) {
          await _storageService.saveToken(token);

          if (mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  // 🚀 CORREGIDO: Usamos la variable 'token' y quitamos 'const'
                  builder: (_) => MainScreen(accessToken: token),
                ),
                    (route) => false
            );
          }
        } else {
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BirthDateScreen(
                        accessToken: token,
                        email: email
                    )
                )
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('Bienvenido a Inklop', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text('Monetiza tu creatividad hoy mismo', style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
              const Spacer(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.black))
              else ...[
                SocialButton(
                  iconPath: 'assets/images/google_icon.png',
                  label: 'Continuar con Google',
                  onTap: () => _handleSocialAuth('google-oauth2'),
                ),
                const SizedBox(height: 16),
                SocialButton(
                  iconPath: 'assets/images/apple_icon.png',
                  label: 'Continuar con Apple',
                  onTap: () => _handleSocialAuth('apple'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EmailAuthScreen())
                    );
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: const Text('Continuar con Correo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                )
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}