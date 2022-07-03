// To parse this JSON data, do
//
//     final stripePaymentIntentRequest = stripePaymentIntentRequestFromJson(jsonString);

import 'dart:convert';

StripePaymentIntentRequest stripePaymentIntentRequestFromJson(String str) =>
    StripePaymentIntentRequest.fromJson(json.decode(str));

String stripePaymentIntentRequestToJson(StripePaymentIntentRequest data) =>
    json.encode(data.toJson());

class StripePaymentIntentRequest {
  StripePaymentIntentRequest({
    required this.email,
    required this.customerId,
    required this.amount,
    required this.paymentMethodId,
    required this.returnUrl,
    required this.applicationFee,
    required this.destination,
  });

  final String email;
  final String customerId;
  final String amount;
  final String paymentMethodId;
  final String returnUrl;
  final String applicationFee;
  final String destination;

  factory StripePaymentIntentRequest.fromJson(Map<String, dynamic> json) =>
      StripePaymentIntentRequest(
        email: json["email"],
        customerId: json["customer_id"],
        amount: json["amount"],
        paymentMethodId: json["payment_method_id"],
        returnUrl: json["return_url"],
        applicationFee: json["application_fee"],
        destination: json["destination"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "customer_id": customerId,
        "amount": amount,
        "payment_method_id": paymentMethodId,
        "return_url": returnUrl,
        "application_fee": applicationFee,
        "destination": destination,
      }..removeWhere((key, value) => value == null);
}
