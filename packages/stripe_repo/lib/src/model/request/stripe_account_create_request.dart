// To parse this JSON data, do
//
//     final StripeAccountCreateRequest = StripeAccountCreateRequestFromJson(jsonString);

import 'dart:convert';

StripeAccountCreateRequest stripeAccountCreateRequestFromJson(String str) =>
    StripeAccountCreateRequest.fromJson(json.decode(str));

String stripeAccountCreateRequestToJson(StripeAccountCreateRequest data) =>
    json.encode(data.toJson());

class StripeAccountCreateRequest {
  StripeAccountCreateRequest(
      {required this.email,
      required this.firstName,
      this.lastName,
      this.phone,
      required this.type});

  final String email;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String type;

  factory StripeAccountCreateRequest.fromJson(Map<String, dynamic> json) =>
      StripeAccountCreateRequest(
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "type": type,
      };
}
