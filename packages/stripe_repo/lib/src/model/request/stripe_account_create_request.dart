// To parse this JSON data, do
//
//     final StripeAccountCreateRequest = StripeAccountCreateRequestFromJson(jsonString);

import 'dart:convert';

StripeAccountCreateRequest stripeAccountCreateRequestFromJson(String str) =>
    StripeAccountCreateRequest.fromJson(json.decode(str));

String stripeAccountCreateRequestToJson(StripeAccountCreateRequest data) =>
    json.encode(data.toJson());

class StripeAccountCreateRequest {
  StripeAccountCreateRequest({
    required this.email,
  });

  final String email;

  factory StripeAccountCreateRequest.fromJson(Map<String, dynamic> json) =>
      StripeAccountCreateRequest(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}
