import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'models/campaign_model.dart';

class CampaignApiService {

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'accept': '*/*',
  };

  void _printDebug(String title, String token, [dynamic body]) {
    print('\n======================================================');
    print('🚀 [DEBUG API] $title');
    print('🔑 TOKEN: Bearer $token');
    if (body != null) print('📦 BODY: ${jsonEncode(body)}');
    print('======================================================\n');
  }

  // --- 1. OBTENER CAMPAÑAS ACTIVAS ---
  Future<List<Campaign>?> getActiveCampaigns(String token) async {
    _printDebug('GET ACTIVE CAMPAIGNS', token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/campaign/active');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => Campaign.fromJson(item)).toList();
      }
    } catch (e) {
      print("❌ Error en getActiveCampaigns: $e");
    }
    return null;
  }

  // --- 2. OBTENER CUENTAS VERIFICADAS ---
  // 🚀 CAMBIO: Renombrado a getVerifiedAccounts y filtrado por isVerified
  Future<List<dynamic>> getVerifiedAccounts(String token) async {
    _printDebug('GET VERIFIED SOCIAL ACCOUNTS', token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/socialmedias-by-user');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        // Filtramos para devolver solo las cuentas que pasaron la verificación
        return body.where((acc) => acc['isVerified'] == true).toList();
      }
    } catch (e) {
      print("❌ Error en getVerifiedAccounts: $e");
    }
    return [];
  }

  // --- 3. OBTENER VIDEOS DE PERFIL (SCRAPING) ---
  Future<List<SocialVideo>> getProfileVideos(String token, int socialMediaId) async {
    _printDebug('GET PROFILE VIDEOS ($socialMediaId)', token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/socialmedia/get-profile-videos/$socialMediaId');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => SocialVideo.fromJson(item)).toList();
      }
    } catch (e) {
      print("❌ Error en getProfileVideos: $e");
    }
    return [];
  }

  // --- 4. POSTULAR A UNA CAMPAÑA (SUBMISSION) ---
  Future<SubmissionResponse?> submitToCampaign(String token, {
    required int socialMediaId,
    required int campaignId,
    required String videoUrl,
  }) async {
    final body = {
      "socialMediaId": socialMediaId,
      "campaignId": campaignId,
      "videoUrl": videoUrl
    };

    _printDebug('POST SUBMISSION', token, body);

    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/submissions');
      final response = await http.post(
          url,
          headers: _headers(token),
          body: jsonEncode(body)
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SubmissionResponse.fromJson(jsonDecode(response.body));
      } else {
        // 🚀 MAPEAMOS EL ERROR
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = errorData['message'] ?? 'Error al procesar';

        // 🛠️ Traducción manual para que sea corto y en español
        if (errorMessage.contains("Is not a video post")) {
          errorMessage = "Este post no es un video";
        }

        throw errorMessage;
      }
    } catch (e) {
      print("❌ Error en submitToCampaign: $e");
      rethrow;
    }
  }

  // --- 5. DETALLES DE UNA POSTULACIÓN ---
  Future<Map<String, dynamic>?> getSubmissionDetails(String token, int submissionId) async {
    _printDebug('GET SUBMISSION DETAILS ($submissionId)', token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/submissions/$submissionId');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("❌ Error en getSubmissionDetails: $e");
    }
    return null;
  }

  // --- 6. ESTADO DE COBRO / PAGOS DEL SUBMISSION ---
  Future<Map<String, dynamic>?> getSubmissionPayment(String token, int submissionId) async {
    _printDebug('GET SUBMISSION PAYMENT ($submissionId)', token);
    try {
      final url = Uri.parse('${AppConstants.apiBaseUrl}/submissions/payment/$submissionId');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("❌ Error en getSubmissionPayment: $e");
    }
    return null;
  }

  // --- 7. GENERAR GUION CON IA ---
  // En lib/features/campaigns/data/campaign_api_service.dart

  Future<Map<String, dynamic>?> getAiScript(int campaignId, String token) async {
    try {
      // 🚀 Ruta exacta según tu Swagger: /campaign/ai/script/campaignId/{id}
      final url = Uri.parse('${AppConstants.apiBaseUrl}/campaign/ai/script/campaignId/$campaignId');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        // Retorna { "format": "...", "has_script": true, "script": "..." }
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print("❌ Error API IA: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error de red IA: $e");
    }
    return null;
  }
  // --- 8. OBTENER TODAS MIS POSTULACIONES ---
  // En lib/features/campaigns/data/campaign_api_service.dart

  Future<List<dynamic>?> getMySubmissions(String token) async {
    try {
      // IMPORTANTE: Verifica que esta URL sea la que te devuelve el array de postulaciones
      final url = Uri.parse('${AppConstants.apiBaseUrl}/submissions/my-submissions');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("❌ Error en getMySubmissions: $e");
    }
    return null;
  }
}