// To parse this JSON data, do
//
//     final stripeRefundRequest = stripeRefundRequestFromJson(jsonString);

import 'dart:convert';

StripeRefundRequest stripeRefundRequestFromJson(String str) =>
    StripeRefundRequest.fromJson(json.decode(str));

String stripeRefundRequestToJson(StripeRefundRequest data) =>
    json.encode(data.toJson());

class StripeRefundRequest {
  StripeRefundRequest(
      {required this.charge, this.reverseTransfer, this.refundApplicationFee});

  final String charge;
  final bool? reverseTransfer;
  final bool? refundApplicationFee;

  factory StripeRefundRequest.fromJson(Map<String, dynamic> json) =>
      StripeRefundRequest(
        charge: json["charge"],
        reverseTransfer: json["reverse_transfer"],
        refundApplicationFee: json["refund_application_fee"],
      );

  Map<String, dynamic> toJson() => {
        "charge": charge,
        "reverse_transfer": reverseTransfer,
        "refund_application_fee": refundApplicationFee,
      }..removeWhere((key, value) => value == null);
}
