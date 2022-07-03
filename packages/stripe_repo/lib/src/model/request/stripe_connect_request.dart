// To parse this JSON data, do
//
//     final stripeConnectRequest = stripeConnectRequestFromJson(jsonString);

import 'dart:convert';

StripeConnectRequest stripeConnectRequestFromJson(String str) =>
    StripeConnectRequest.fromJson(json.decode(str));

String stripeConnectRequestToJson(StripeConnectRequest data) =>
    json.encode(data.toJson());

class StripeConnectRequest {
  StripeConnectRequest({
    required this.email,
    required this.accountId,
    required this.refreshUrl,
    required this.returnUrl,
  });

  final String email;
  final String accountId;
  final String refreshUrl;
  final String returnUrl;

  factory StripeConnectRequest.fromJson(Map<String, dynamic> json) =>
      StripeConnectRequest(
        email: json["email"],
        accountId: json["account_id"],
        refreshUrl: json["refresh_url"],
        returnUrl: json["return_url"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "account_id": accountId,
        "refresh_url": refreshUrl,
        "return_url": returnUrl,
      };
}
