// To parse this JSON data, do
//
//     final stripeAccountBalanceResponse = stripeAccountBalanceResponseFromJson(jsonString);

import 'dart:convert';

StripeAccountBalanceResponse stripeAccountBalanceResponseFromJson(String str) =>
    StripeAccountBalanceResponse.fromJson(json.decode(str));

String stripeAccountBalanceResponseToJson(StripeAccountBalanceResponse data) =>
    json.encode(data.toJson());

class StripeAccountBalanceResponse {
  StripeAccountBalanceResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final _Data data;

  factory StripeAccountBalanceResponse.fromJson(Map<String, dynamic> json) =>
      StripeAccountBalanceResponse(
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
    required this.object,
    required this.available,
    required this.instantAvailable,
    required this.livemode,
    required this.pending,
  });

  final String object;
  final List<_Available> available;
  final List<_Available> instantAvailable;
  final bool livemode;
  final List<_Available> pending;

  factory _Data.fromJson(Map<String, dynamic> json) => _Data(
        object: json["object"],
        available: List<_Available>.from(
            json["available"].map((x) => _Available.fromJson(x))),
        instantAvailable: List<_Available>.from(
            json["instant_available"].map((x) => _Available.fromJson(x))),
        livemode: json["livemode"],
        pending: List<_Available>.from(
            json["pending"].map((x) => _Available.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "available": List<dynamic>.from(available.map((x) => x.toJson())),
        "instant_available":
            List<dynamic>.from(instantAvailable.map((x) => x.toJson())),
        "livemode": livemode,
        "pending": List<dynamic>.from(pending.map((x) => x.toJson())),
      };
}

class _Available {
  _Available({
    required this.amount,
    required this.currency,
    required this.sourceTypes,
  });

  final int amount;
  final String currency;
  final _SourceTypes sourceTypes;

  factory _Available.fromJson(Map<String, dynamic> json) => _Available(
        amount: json["amount"],
        currency: json["currency"],
        sourceTypes: _SourceTypes.fromJson(json["source_types"]),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "currency": currency,
        "source_types": sourceTypes.toJson(),
      };
}

class _SourceTypes {
  _SourceTypes({
    required this.card,
  });

  final int card;

  factory _SourceTypes.fromJson(Map<String, dynamic> json) => _SourceTypes(
        card: json["card"],
      );

  Map<String, dynamic> toJson() => {
        "card": card,
      };
}
