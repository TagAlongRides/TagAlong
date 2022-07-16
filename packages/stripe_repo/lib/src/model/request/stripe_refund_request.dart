// To parse this JSON data, do
//
//     final stripeRefundRequest = stripeRefundRequestFromJson(jsonString);

import 'dart:convert';

StripeRefundRequest stripeRefundRequestFromJson(String str) =>
    StripeRefundRequest.fromJson(json.decode(str));

String stripeRefundRequestToJson(StripeRefundRequest data) =>
    json.encode(data.toJson());

class StripeRefundRequest {
  StripeRefundRequest({
    required this.charge,
  });

  final String charge;

  factory StripeRefundRequest.fromJson(Map<String, dynamic> json) =>
      StripeRefundRequest(
        charge: json["charge"],
      );

  Map<String, dynamic> toJson() => {
        "charge": charge,
      };
}
