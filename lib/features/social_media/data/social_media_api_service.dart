import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import 'models/social_media_model.dart';

class SocialMediaApiService {
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'accept': '*/*',
  };

  // POST: Vincular cuenta inicial
  Future<SocialMediaAccount?> linkAccount(String platform, String link, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia');
    try {
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode({"platform": platform, "link": link}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SocialMediaAccount.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("Error linking account: $e");
    }
    return null;
  }

  // GET: Listar todas las redes del usuario
  Future<List<SocialMediaAccount>> getMySocialMedias(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/socialmedias_by_user');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => SocialMediaAccount.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching accounts: $e");
    }
    return [];
  }

  // GET: Ejecutar algoritmo de verificación — lee isVerified del body
  Future<bool> verifyAccount(int id, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/verificate/$id');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['isVerified'] == true;
      }
      return false;
    } catch (e) {
      print("Error verifying account: $e");
      return false;
    }
  }

  // DELETE: Eliminar vinculación
  Future<bool> deleteAccount(int id, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/socialmedia/$id');
    print('DELETE → $url');
    try {
      final response = await http.delete(url, headers: _headers(token));
      print('DELETE status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error deleting account: $e");
      return false;
    }
  }
  // GET: Obtener todas las cuentas del usuario
  Future<List?> getAccountsByUser(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/socialmedias-by-user');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Error getAccountsByUser: $e");
    }
    return null;
  }
}