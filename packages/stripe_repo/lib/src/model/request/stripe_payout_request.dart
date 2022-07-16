// To parse this JSON data, do
//
//     final stripePayoutRequest = stripePayoutRequestFromJson(jsonString);

import 'dart:convert';

StripePayoutRequest stripePayoutRequestFromJson(String str) =>
    StripePayoutRequest.fromJson(json.decode(str));

String stripePayoutRequestToJson(StripePayoutRequest data) =>
    json.encode(data.toJson());

class StripePayoutRequest {
  StripePayoutRequest({
    required this.amount,
    required this.accountId,
  });

  final String amount;
  final String accountId;

  factory StripePayoutRequest.fromJson(Map<String, dynamic> json) =>
      StripePayoutRequest(
        amount: json["amount"],
        accountId: json["account_id"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "account_id": accountId,
      };
}
