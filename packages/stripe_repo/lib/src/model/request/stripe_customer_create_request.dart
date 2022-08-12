// To parse this JSON data, do
//
//     final StripeCustomerCreateRequest = StripeAccountCreateRequestFromJson(jsonString);

import 'dart:convert';

StripeCustomerCreateRequest stripeCustomerCreateRequestFromJson(String str) =>
    StripeCustomerCreateRequest.fromJson(json.decode(str));

String stripeCustomerCreateRequestToJson(StripeCustomerCreateRequest data) =>
    json.encode(data.toJson());

class StripeCustomerCreateRequest {
  StripeCustomerCreateRequest({
    required this.email,
    required this.name,
  });

  final String email;
  final String name;

  factory StripeCustomerCreateRequest.fromJson(Map<String, dynamic> json) =>
      StripeCustomerCreateRequest(
        email: json["email"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
      };
}
