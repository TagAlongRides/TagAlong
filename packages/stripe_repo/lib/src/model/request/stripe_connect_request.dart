// To parse this JSON data, do
//
//     final stripeConnectRequest = stripeConnectRequestFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/gestures.dart';

StripeConnectRequest stripeConnectRequestFromJson(String str) => StripeConnectRequest.fromJson(json.decode(str));

String stripeConnectRequestToJson(StripeConnectRequest data) => json.encode(data.toJson());

class StripeConnectRequest {
  StripeConnectRequest({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.accountId,
    required this.refreshUrl,
    required this.returnUrl,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String accountId;
  final String refreshUrl;
  final String returnUrl;

  factory StripeConnectRequest.fromJson(Map<String, dynamic> json) => StripeConnectRequest(
        firstName: json["first_name"],
        lastName: json["last_name"],
        phoneNumber: json["phone"],
        email: json["email"],
        accountId: json["account_id"],
        refreshUrl: json["refresh_url"],
        returnUrl: json["return_url"],
      );

  Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "phone": phoneNumber,
        "email": email,
        "account_id": accountId,
        "refresh_url": refreshUrl,
        "return_url": returnUrl,
      };
}
