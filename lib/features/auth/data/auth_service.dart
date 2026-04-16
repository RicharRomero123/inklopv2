import 'package:auth0_flutter/auth0_flutter.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  // Inicialización de Auth0 usando las constantes del proyecto
  final Auth0 _auth0 = Auth0(AppConstants.auth0Domain, AppConstants.auth0ClientId);

  // ── 1. LOGIN SOCIAL (Google / Apple) ──────────────────────────────────────
  Future<Map<String, String?>> loginSocialWithDetails(String connection) async {
    try {
      final credentials = await _auth0.webAuthentication(scheme: AppConstants.auth0Scheme).login(
        audience: AppConstants.auth0Audience,
        // 🚀 'offline_access' es vital para obtener el Refresh Token
        scopes: {'openid', 'profile', 'email', 'offline_access'},
        parameters: {'connection': connection},
      );

      return {
        'token': credentials.accessToken,
        'refreshToken': credentials.refreshToken,
        'email': credentials.user.email,
      };
    } catch (e) {
      throw Exception('Error en login social: $e');
    }
  }

  // ── 2. LOGIN CON EMAIL (Base de Datos / Password) ──────────────────────────
  Future<Map<String, String?>> loginWithEmail(String email, String password) async {
    try {
      final credentials = await _auth0.api.login(
        usernameOrEmail: email,
        password: password,
        connectionOrRealm: 'Username-Password-Authentication',
        audience: AppConstants.auth0Audience,
        // 🚀 Aseguramos que el scope esté presente aquí también
        scopes: {'openid', 'profile', 'email', 'offline_access'},
      );

      return {
        'token': credentials.accessToken,
        'refreshToken': credentials.refreshToken,
      };
    } catch (e) {
      throw Exception('Error en login con email: $e');
    }
  }

  // ── 3. RENOVAR TOKEN (Silent Auth) ─────────────────────────────────────────
  Future<Map<String, String?>> renewToken(String refreshToken) async {
    try {
      // Intercambiamos el refresh_token por un set de credenciales nuevas
      final credentials = await _auth0.api.renewCredentials(refreshToken: refreshToken);

      return {
        'token': credentials.accessToken,
        'refreshToken': credentials.refreshToken, // Auth0 puede rotar el token aquí
      };
    } catch (e) {
      throw Exception('Error al refrescar la sesión: $e');
    }
  }

  // ── 4. REGISTRO DE USUARIO ────────────────────────────────────────────────
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _auth0.api.signup(
        email: email,
        password: password,
        connection: 'Username-Password-Authentication',
      );
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }
}