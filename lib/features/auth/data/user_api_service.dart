import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class UserApiService {
  // 🔑 Función para imprimir el token en consola siempre (Corregido el nombre)
  void _printDebugToken(String token) {
    print('\n======================================================');
    print('🔑 [DEBUG] BEARER TOKEN:');
    print('Bearer $token');
    print('======================================================\n');
  }

  // --- 1. VALIDAR DISPONIBILIDAD DE USERNAME ---
  // Según tu Swagger: { "exists": false, "valid": true } es el estado disponible.
  Future<Map<String, dynamic>> checkUsername(String username, String token) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/check-username/$username');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      print('📡 Check Username ($username) Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('❌ Error Check Username: ${response.body}');
        return {'valid': false, 'exists': true};
      }
    } catch (e) {
      print('❌ Excepción en Check Username: $e');
      return {'valid': false, 'exists': true};
    }
  }

  // --- 2. OBTENER DATOS DE FIRMA (NUEVA ESTRUCTURA) ---
  Future<Map<String, dynamic>?> getCloudinarySignature(String token) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/files/signature');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      print('📡 GET SIGNATURE STATUS: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ ESTRUCTURA RECIBIDA: $data');
        return data;
      }
    } catch (e) {
      print("❌ ERROR SIGNATURE: $e");
    }
    return null;
  }

  // --- 3. SUBIR A CLOUDINARY (DINÁMICO) ---
  Future<String?> uploadToCloudinary(File imageFile, Map<String, dynamic> sigData) async {
    try {
      final String uploadUrl = sigData['url'];
      final Map<String, dynamic> bodyFields = sigData['body'];

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // MAPEADO DINÁMICO de todos los campos del body (api_key, signature, folder, etc.)
      bodyFields.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      print('☁️ SUBIENDO A CLOUDINARY... URL: $uploadUrl');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = jsonDecode(response.body);
        print('✅ URL GENERADA: ${resData['secure_url']}');
        return resData['secure_url'];
      } else {
        print('❌ ERROR CLOUDINARY: ${response.body}');
      }
    } catch (e) {
      print("❌ EXCEPCIÓN CLOUDINARY: $e");
    }
    return null;
  }

  // --- 4. REGISTRAR PERFIL DE CREADOR ---
  Future<bool> registerCreatorProfile({
    required Map<String, dynamic> payload,
    required String token,
  }) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me/creator-profile');

      print('📤 Enviando JSON al Backend: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(payload),
      );

      print('📥 Status Registro: ${response.statusCode}');
      print('📥 Respuesta Registro: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error en POST Registro: $e");
      return false;
    }
  }

  // --- 5. VERIFICAR SI EL PERFIL YA EXISTE ---
  Future<bool> isProfileCompleted(String token) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/users/me');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['profileCompleted'] == true;
      }
    } catch (e) {
      print("❌ Error verificando perfil: $e");
    }
    return false;
  }
}