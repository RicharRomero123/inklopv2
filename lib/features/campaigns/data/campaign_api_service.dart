import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'models/campaign_model.dart';

class CampaignApiService {
  void _printDebugToken(String token) {
    print('\n======================================================');
    print('🔑 [DEBUG] BEARER TOKEN CAMPAIGNS:');
    print('Bearer $token');
    print('======================================================\n');
  }

  // --- 1. OBTENER CAMPAÑAS ACTIVAS ---
  Future<List<Campaign>?> getActiveCampaigns(String token) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/campaign/active');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) => Campaign.fromJson(item)).toList();
      }
    } catch (e) {
      print("❌ Error al obtener campañas: $e");
    }
    return null;
  }

  // --- 2. GENERAR GUION CON IA (MARKDOWN) ---
  Future<Map<String, dynamic>?> getAiScript(int campaignId, String token) async {
    _printDebugToken(token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/campaign/ai/script/campaignId/$campaignId');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("❌ Error al generar guion: $e");
    }
    return null;
  }
}