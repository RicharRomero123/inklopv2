import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  // 🚀 Definimos las llaves como constantes para evitar errores de dedo
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  /// Guarda ambos tokens al mismo tiempo (útil en el Login o Registro)
  Future<void> saveToken({required String access, required String refresh}) async {
    await _storage.write(key: _tokenKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  /// Guarda solo el access token (útil cuando haces el Refresh exitoso)
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Recupera el Access Token para las peticiones a la API
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Recupera el Refresh Token para renovar la sesión
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  /// Borra absolutamente todo (Ideal para el botón de "Cerrar Sesión" que hicimos)
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    // O puedes borrar llaves específicas:
    // await _storage.delete(key: _tokenKey);
    // await _storage.delete(key: _refreshKey);
  }
}