import 'dart:convert';

StripePaymentIntentCreateResponse stripePaymentIntentCreateResponseFromJson(String str) =>
    StripePaymentIntentCreateResponse.fromJson(json.decode(str));

String stripePaymentIntentCreateResponseToJson(StripePaymentIntentCreateResponse data) =>
    json.encode(data.toJson());

/// The result of charging a passenger for a ride.
///
/// This used to deserialise the whole PaymentIntent object into roughly sixty
/// `required` non-nullable fields. Two problems with that, both of which cost
/// real money rather than just throwing:
///
/// 1. Stripe nulls most optional fields on a PaymentIntent, so any of them
///    could throw *after* the passenger's card had already been charged -
///    leaving money taken and no booking recorded.
/// 2. It read the charge id from `charges.data[0].id`. Stripe removed
///    `charges` from PaymentIntent in API version 2022-11-15, replacing it
///    with `latest_charge`. The backend runs on a much later version, so that
///    field is simply absent.
///
/// Only `id`, `status`, `client_secret` and the charge id are used anywhere.
class StripePaymentIntentCreateResponse {
  StripePaymentIntentCreateResponse({
    this.status,
    this.success,
    this.message,
    required this.data,
  });

  final int? status;
  final bool? success;
  final String? message;
  final StripePaymentIntent data;

  factory StripePaymentIntentCreateResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    if (payload is! Map) {
      throw FormatException(
        'Payment intent response had no data object: ${json['message'] ?? json}',
      );
    }
    return StripePaymentIntentCreateResponse(
      status: _asInt(json['status']),
      success: json['success'] as bool?,
      message: json['message']?.toString(),
      data: StripePaymentIntent.fromJson(Map<String, dynamic>.from(payload)),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

class StripePaymentIntent {
  StripePaymentIntent({
    required this.id,
    required this.status,
    this.clientSecret,
    this.latestChargeId,
    this.amount,
    this.currency,
    this.raw = const {},
  });

  /// The `pi_...` id, recorded against the booking.
  final String id;

  /// `succeeded`, `requires_action`, and so on. The booking flow branches on
  /// this, so a response without it is unusable.
  final String status;

  /// Needed to complete 3D Secure. Absent unless action is required.
  final String? clientSecret;

  /// The `ch_...` id behind this payment.
  ///
  /// Read from `latest_charge`, falling back to the pre-2022-11-15
  /// `charges.data[0].id` so an older backend keeps working. Null when Stripe
  /// has not settled a charge yet.
  ///
  /// This is what links a Stripe dispute back to a booking. It is worth
  /// having, but not worth failing a paid booking over: the dispute handler
  /// also matches on the payment intent id.
  final String? latestChargeId;

  final int? amount;
  final String? currency;

  /// The unmodified payload, for logging and for fields not modelled.
  final Map<String, dynamic> raw;

  factory StripePaymentIntent.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw FormatException('Payment intent response had no id: $json');
    }

    final status = json['status'];
    if (status is! String || status.isEmpty) {
      throw FormatException('Payment intent $id had no status');
    }

    return StripePaymentIntent(
      id: id,
      status: status,
      clientSecret: json['client_secret']?.toString(),
      latestChargeId: _chargeId(json),
      amount: _asInt(json['amount']),
      currency: json['currency']?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {
          'id': id,
          'status': status,
          'client_secret': clientSecret,
          'latest_charge': latestChargeId,
          'amount': amount,
          'currency': currency,
        };
}

/// `latest_charge` may be an id or an expanded Charge. `charges` is the
/// removed pre-2022-11-15 shape, kept so an older backend still works.
String? _chargeId(Map<String, dynamic> json) {
  final latest = json['latest_charge'];
  if (latest is String && latest.isNotEmpty) return latest;
  if (latest is Map && latest['id'] is String) return latest['id'] as String;

  final charges = json['charges'];
  if (charges is Map) {
    final data = charges['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map && first['id'] is String) return first['id'] as String;
    }
  }
  return null;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
