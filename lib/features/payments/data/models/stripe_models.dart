class StripeAccountRequest {
  final String firstName;
  final String lastName;
  final String birthDate; // Formato "YYYY-MM-DD"
  final String email;
  final String phoneNumber;
  final String externalBankAccount;
  final String city;
  final String line1;
  final String postalCode;
  final String state;
  final String currency;

  StripeAccountRequest({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phoneNumber,
    required this.externalBankAccount,
    required this.city,
    required this.line1,
    required this.postalCode,
    required this.state,
    this.currency = "USD",
  });

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "birthDate": birthDate,
    "email": email,
    "phoneNumber": phoneNumber,
    "externalBankAccount": externalBankAccount,
    "city": city,
    "line1": line1,
    "postalCode": postalCode,
    "state": state,
    "currency": currency,
  };
}
// lib/features/payments/data/models/stripe_models.dart

class StripeAccountLinkResponse {
  final String url;
  final DateTime expiresAt;

  StripeAccountLinkResponse({required this.url, required this.expiresAt});

  factory StripeAccountLinkResponse.fromJson(Map<String, dynamic> json) => StripeAccountLinkResponse(
    url: json['url'],
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

class StripeAccountResponse {
  final String connectedAccountId;
  final String externalAccountId;

  StripeAccountResponse({required this.connectedAccountId, required this.externalAccountId});

  factory StripeAccountResponse.fromJson(Map<String, dynamic> json) => StripeAccountResponse(
    connectedAccountId: json['connectedAccountId'],
    externalAccountId: json['externalAccountId'],
  );
}
// Agrega esta clase a tu archivo stripe_models.dart existente

class StripeProfileStatus {
  final bool completed;
  final dynamic pending; // null o datos adicionales según el backend

  StripeProfileStatus({required this.completed, this.pending});

  factory StripeProfileStatus.fromJson(Map<String, dynamic> json) {
    return StripeProfileStatus(
      completed: json['completed'] as bool,
      pending: json['pending'],
    );
  }
}