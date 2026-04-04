import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/constants/app_constants.dart';

class ProfileApiService {
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // GET: Obtener mi perfil completo
  Future<Map<String, dynamic>?> getMyProfile(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me'); // Ajusté el prefijo común /api/v1
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      print("Error profile GET: $e");
    }
    return null;
  }

  // GET: Validar disponibilidad de username
  Future<Map<String, dynamic>?> checkUsername(String token, String username) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/users/check-username/$username');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {
      print("Error check-username: $e");
    }
    return null;
  }

  // PUT: Actualizar datos básicos (Mapeo completo)
  Future<bool> updateProfile(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me');
    try {
      final response = await http.put(
          url,
          headers: _headers(token),
          body: jsonEncode(data)
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error profile PUT: $e");
      return false;
    }
  }

  // PUT: Actualizar Imagen
  Future<bool> updateProfileImage(String token, File imageFile) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me/image');
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    return streamedResponse.statusCode == 200;
  }
}