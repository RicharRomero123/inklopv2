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

  // GET: Ejecutar algoritmo de verificación
  Future<bool> verifyAccount(int id, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/verificate/$id');
    try {
      final response = await http.get(url, headers: _headers(token));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // DELETE: Eliminar vinculación
  Future<bool> deleteAccount(int id, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/socialmedia/$id');
    try {
      final response = await http.delete(url, headers: _headers(token));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}