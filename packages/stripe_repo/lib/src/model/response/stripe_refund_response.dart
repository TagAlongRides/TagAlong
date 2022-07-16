// To parse this JSON data, do
//
//     final stripeRefundResponse = stripeRefundResponseFromJson(jsonString);

import 'dart:convert';

StripeRefundResponse stripeRefundResponseFromJson(String str) =>
    StripeRefundResponse.fromJson(json.decode(str));

String stripeRefundResponseToJson(StripeRefundResponse data) =>
    json.encode(data.toJson());

class StripeRefundResponse {
  StripeRefundResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final _Data data;

  factory StripeRefundResponse.fromJson(Map<String, dynamic> json) =>
      StripeRefundResponse(
        status: json["status"],
        success: json["success"],
        message: json["message"],
        data: _Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class _Data {
  _Data({
    required this.id,
    required this.object,
    required this.amount,
    required this.balanceTransaction,
    required this.charge,
    required this.created,
    required this.currency,
    required this.metadata,
    required this.paymentIntent,
    required this.reason,
    required this.receiptNumber,
    required this.sourceTransferReversal,
    required this.status,
    required this.transferReversal,
  });

  final String id;
  final String object;
  final int amount;
  final String balanceTransaction;
  final String charge;
  final int created;
  final String currency;
  final _Metadata metadata;
  final String paymentIntent;
  final dynamic reason;
  final dynamic receiptNumber;
  final dynamic sourceTransferReversal;
  final String status;
  final dynamic transferReversal;

  factory _Data.fromJson(Map<String, dynamic> json) => _Data(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        balanceTransaction: json["balance_transaction"],
        charge: json["charge"],
        created: json["created"],
        currency: json["currency"],
        metadata: _Metadata.fromJson(json["metadata"]),
        paymentIntent: json["payment_intent"],
        reason: json["reason"],
        receiptNumber: json["receipt_number"],
        sourceTransferReversal: json["source_transfer_reversal"],
        status: json["status"],
        transferReversal: json["transfer_reversal"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "balance_transaction": balanceTransaction,
        "charge": charge,
        "created": created,
        "currency": currency,
        "metadata": metadata.toJson(),
        "payment_intent": paymentIntent,
        "reason": reason,
        "receipt_number": receiptNumber,
        "source_transfer_reversal": sourceTransferReversal,
        "status": status,
        "transfer_reversal": transferReversal,
      };
}

class _Metadata {
  _Metadata();

  factory _Metadata.fromJson(Map<String, dynamic> json) => _Metadata();

  Map<String, dynamic> toJson() => {};
}
