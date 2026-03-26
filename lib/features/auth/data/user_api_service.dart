import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'package:http_parser/http_parser.dart'; // NECESARIO

class UserApiService {

  // --- 1. CONSULTAR USERNAME (GET) ---
  Future<Map<String, dynamic>> checkUsername(String username, String token) async {
    try {
      // 🚨 IMPRESIÓN DEL TOKEN PARA PROBAR EN SWAGGER 🚨
      print('\n======================================================');
      print('🔑 BEARER TOKEN OBTENIDO (Cópialo para usar en Swagger):');
      print(token);
      print('======================================================\n');

      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/check-username/$username');

      final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 Respuesta API Username ($username): $data');
        return data;
      }

      print('❌ Error API Username. Status: ${response.statusCode}');
      return {'valid': false, 'exists': false};
    } catch (e) {
      print('❌ Error de red al consultar Username: $e');
      return {'valid': false, 'exists': false};
    }
  }

  // --- 2. ENVIAR PERFIL COMPLETO (POST MULTIPART) ---
  Future<bool> registerCreatorProfile({
    required Map<String, dynamic> payload,
    required String token,
    File? imageFile
  }) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me/creator-profile');
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Enviamos el objeto 'data' como una parte JSON
      request.files.add(http.MultipartFile.fromString(
        'data',
        jsonEncode(payload),
        contentType: MediaType('application', 'json'),
      ));

      // Enviamos el archivo 'file'
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        throw Exception('La foto de perfil es obligatoria');
      }

      print('🚀 Enviando Registro a: $url');
      print('📦 Payload enviado: ${jsonEncode(payload)}');

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Respuesta (Status ${response.statusCode}): ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error en registerCreatorProfile: $e');
      return false;
    }
  }

  // --- 4. SUBIR FOTO DE PERFIL (PUT - Multipart) ---
  Future<bool> uploadProfileImage(String imagePath, String token) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me/image');
      print('\n📸 Subiendo imagen de perfil a: $url');

      // Creamos la petición Multipart para subir archivos
      var request = http.MultipartRequest('PUT', url);

      // Agregamos el Token
      request.headers['Authorization'] = 'Bearer $token';

      // Agregamos el archivo al campo 'file' (como lo pide tu Swagger)
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      // Enviamos la petición
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Respuesta PUT Imagen (Status ${response.statusCode}): ${response.body}\n');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error al subir imagen de perfil: $e');
      return false;
    }
  }

  // --- 3. VERIFICAR SI EL PERFIL YA ESTÁ COMPLETO (GET) ---
  Future<bool> isProfileCompleted(String token) async {
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me');

      print('🔍 Verificando si el usuario ya existe en: $url');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isCompleted = data['profileCompleted'] == true;

        print('✅ Usuario encontrado en BD: ${data['username'] ?? 'Sin username'}');
        print('🚦 ¿Perfil completado?: $isCompleted');

        return isCompleted;
      }

      // Si el servidor responde 404, 500 u otro error
      print('⚠️ El usuario aún no existe en BD o hubo error (Status: ${response.statusCode})');
      return false;

    } catch (e) {
      print('❌ Error de red al verificar perfil: $e');
      return false; // Ante la duda o error de red, asumimos que no está completo
    }
  }
}