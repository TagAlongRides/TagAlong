// To parse this JSON data, do
//
//     final stripeConnectResponse = stripeConnectResponseFromJson(jsonString);

import 'dart:convert';

StripeConnectResponse stripeConnectResponseFromJson(String str) =>
    StripeConnectResponse.fromJson(json.decode(str));

String stripeConnectResponseToJson(StripeConnectResponse data) =>
    json.encode(data.toJson());

class StripeConnectResponse {
  StripeConnectResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final Data data;

  factory StripeConnectResponse.fromJson(Map<String, dynamic> json) =>
      StripeConnectResponse(
        status: json["status"],
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.created,
    required this.expiresAt,
    required this.url,
    required this.accountId,
  });

  final int created;
  final int expiresAt;
  final String url;
  final String accountId;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        created: json["created"],
        expiresAt: json["expires_at"],
        url: json["url"],
        accountId: json["account_id"],
      );

  Map<String, dynamic> toJson() => {
        "created": created,
        "expires_at": expiresAt,
        "url": url,
        "account_id": accountId,
      };
}
