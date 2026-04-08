import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'models/stripe_models.dart';

class StripeApiService {
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'accept': '*/*',
  };

  Future<StripeAccountResponse?> createConnectedAccount(
      String token, StripeAccountRequest data) async {
    final url =
    Uri.parse('${AppConstants.apiBaseUrl}/stripe/connected-account');

    final bodyEncoded = jsonEncode(data.toJson());
    print('\n🚀 [STRIPE API] ENVIANDO POST A: $url');
    print('📦 [BODY JSON]:');
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print(encoder.convert(data.toJson()));
    print('------------------------------------------------------\n');

    try {
      final response = await http.post(
        url,
        headers: _headers(token),
        body: bodyEncoded,
      );

      print('📡 [STRIPE API] STATUS CODE: ${response.statusCode}');
      print('📥 [RESPONSE]: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return StripeAccountResponse.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Error en la respuesta: ${response.body}');
      }
    } catch (e) {
      print("❌ Error de red/conexión: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getBalance(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/balance');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("❌ Error fetching balance: $e");
    }
    return null;
  }

  Future<StripeAccountLinkResponse?> generateAccountLink(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/stripe/account-link');
    try {
      final response = await http.post(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return StripeAccountLinkResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error Account Link: $e");
    }
    return null;
  }

  // --- GET /stripe/profile-status ---
  // Retorna { "completed": bool, "pending": null | ... }
  // completed: true  → cuenta Stripe ya conectada y completa
  // completed: false → falta completar el onboarding
  Future<StripeProfileStatus?> getProfileStatus(String token) async {
    final url =
    Uri.parse('${AppConstants.apiBaseUrl}/stripe/profile-status');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        return StripeProfileStatus.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("❌ Error getProfileStatus: $e");
    }
    return null;
  }
}