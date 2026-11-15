import 'dart:convert';

StripeConnectResponse stripeConnectResponseFromJson(String str) =>
    StripeConnectResponse.fromJson(json.decode(str));

String stripeConnectResponseToJson(StripeConnectResponse data) =>
    json.encode(data.toJson());

/// The hosted onboarding link a driver completes in the in-app web view.
///
/// This used to type `created` and `expires_at` as `int`, which held while the
/// backend created links on Accounts v1. Accounts v2 returns ISO-8601 strings
/// for both, so the first v2 link threw
/// "type 'String' is not a subtype of type 'int'" while parsing a response
/// that was otherwise perfectly good.
///
/// Only [StripeAccountLink.url] and [StripeAccountLink.accountId] are read
/// anywhere in the app. The timestamps are parsed leniently, from either
/// format, because an expiry is genuinely useful: v2 account links are single
/// use and last minutes.
class StripeConnectResponse {
  StripeConnectResponse({
    this.status,
    this.success,
    this.message,
    required this.data,
  });

  final int? status;
  final bool? success;
  final String? message;
  final StripeAccountLink data;

  factory StripeConnectResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    if (payload is! Map) {
      throw FormatException(
        'Stripe connect response had no data object: ${json['message'] ?? json}',
      );
    }
    return StripeConnectResponse(
      status: _asInt(json['status']),
      success: json['success'] as bool?,
      message: json['message']?.toString(),
      data: StripeAccountLink.fromJson(Map<String, dynamic>.from(payload)),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class StripeAccountLink {
  StripeAccountLink({
    required this.url,
    required this.accountId,
    this.createdAt,
    this.expiresAt,
    this.raw = const {},
  });

  /// Stripe's hosted onboarding URL. Without it there is nothing to show.
  final String url;

  /// The connected account the link belongs to, stored against the driver.
  final String accountId;

  final DateTime? createdAt;

  /// When the link stops working. Single use, and minutes rather than hours.
  final DateTime? expiresAt;

  /// The unmodified payload, for logging and for fields not modelled.
  final Map<String, dynamic> raw;

  /// Whether this link is already too old to be worth opening.
  ///
  /// False when Stripe gave no expiry: a link that might work beats refusing
  /// to try one.
  bool get hasExpired =>
      expiresAt != null && DateTime.now().toUtc().isAfter(expiresAt!.toUtc());

  factory StripeAccountLink.fromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || url.isEmpty) {
      throw FormatException('Stripe account link had no url: $json');
    }

    // The backend sets account_id explicitly; v2 also returns it as `account`.
    final accountId = json['account_id'] ?? json['account'];
    if (accountId is! String || accountId.isEmpty) {
      throw FormatException('Stripe account link had no account id: $json');
    }

    return StripeAccountLink(
      url: url,
      accountId: accountId,
      createdAt: _timestamp(json['created']),
      expiresAt: _timestamp(json['expires_at']),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {
          'url': url,
          'account_id': accountId,
          'created': createdAt?.toIso8601String(),
          'expires_at': expiresAt?.toIso8601String(),
        };
}

/// Accounts v1 sent epoch seconds, Accounts v2 sends ISO-8601. Accept both,
/// and give up quietly rather than throwing on something unrecognised.
DateTime? _timestamp(Object? value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  final text = value.toString();
  final epoch = int.tryParse(text);
  if (epoch != null) {
    return DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);
  }
  return DateTime.tryParse(text)?.toUtc();
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
