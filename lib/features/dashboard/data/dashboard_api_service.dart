import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/submission_model.dart';

class DashboardApiService {
  final String baseUrl = "https://inklop-backend-dev-develop.up.railway.app/api/v1";

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'accept': '*/*',
  };

  // 1. Obtener todas las postulaciones del creador
  Future<List<UserSubmission>?> getCreatorSubmissions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/submissions/all/creator'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => UserSubmission.fromJson(item)).toList();
      }
    } catch (e) { print("Error Dash API: $e"); }
    return null;
  }

  // 2. Apelar (Flag)
  Future<bool> sendAppeal({
    required String token,
    required int submissionId,
    required String reason,
    String typeAppeal = "OTHER", // Valor por defecto
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/appeals/toCreator'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'accept': '*/*',
        },
        body: jsonEncode({
          "submissionId": submissionId,
          "reason": reason,
          "typeAppeal": typeAppeal,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error enviando apelación: $e");
      return false;
    }
  }

  // 3. Cobrar Campaña
  Future<Map<String, dynamic>?> processPayment(String token, int campaignId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/payment'),
        headers: _headers(token),
        body: jsonEncode({"campaignId": campaignId}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { return null; }
    return null;
  }

}