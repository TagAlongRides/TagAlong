import 'dart:convert';

StripeAccountCreateResponse stripeAccountCreateResponseFromJson(String str) =>
    StripeAccountCreateResponse.fromJson(json.decode(str));

String stripeAccountCreateResponseToJson(StripeAccountCreateResponse data) =>
    json.encode(data.toJson());

/// The response from creating or retrieving a driver's connected account.
///
/// This used to deserialise Stripe's entire Account object into a tree of
/// classes whose fields were all `required` and non-nullable - business
/// profile, settings, branding, card issuing, external accounts, payout
/// schedule. Stripe omits or nulls most of those on a newly created account,
/// so the first successful account creation threw
/// "type 'Null' is not a subtype of type 'String'" while parsing, after the
/// account had already been created on Stripe's side. The driver saw a failure,
/// nothing was saved, and a retry created another orphan account.
///
/// Only [StripeAccount.id] and [StripeAccount.chargesEnabled] are used
/// anywhere in the app, so only those are relied on here. Everything else is
/// optional, and the untouched payload stays available as
/// [StripeAccount.raw] for debugging.
class StripeAccountCreateResponse {
  StripeAccountCreateResponse({
    this.status,
    this.success,
    this.message,
    required this.data,
  });

  final int? status;
  final bool? success;
  final String? message;
  final StripeAccount data;

  factory StripeAccountCreateResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['data'];
    if (payload is! Map) {
      throw FormatException(
        'Stripe account response had no data object: ${json['message'] ?? json}',
      );
    }
    return StripeAccountCreateResponse(
      status: _asInt(json['status']),
      success: json['success'] as bool?,
      message: json['message']?.toString(),
      data: StripeAccount.fromJson(Map<String, dynamic>.from(payload)),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'success': success,
        'message': message,
        'data': data.toJson(),
      };
}

/// A Stripe connected account, reduced to the parts TagAlong uses.
class StripeAccount {
  StripeAccount({
    required this.id,
    this.object,
    this.type,
    this.country,
    this.email,
    this.defaultCurrency,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
    this.detailsSubmitted = false,
    this.capabilities = const {},
    this.raw = const {},
  });

  /// The `acct_...` id. The one field we genuinely cannot continue without.
  final String id;

  final String? object;
  final String? type;
  final String? country;
  final String? email;
  final String? defaultCurrency;

  /// Whether the driver can be paid yet. Defaults to false deliberately: a
  /// missing field must never read as "this driver is ready to take money".
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;

  /// Capability name to status, e.g. `{'transfers': 'pending'}`. Stripe omits
  /// capabilities that were never requested, so absence is normal.
  final Map<String, String> capabilities;

  /// The unmodified account payload, for logging and for fields not modelled.
  final Map<String, dynamic> raw;

  /// Whether this driver can actually be paid.
  ///
  /// Deliberately not [chargesEnabled]. That field describes accepting card
  /// payments, and under Accounts v2 a driver's account is created with only
  /// the `recipient` configuration - no `merchant` - because drivers never
  /// take card payments themselves. So `charges_enabled` stays false no matter
  /// how much onboarding they complete, and using it would leave every driver
  /// looking permanently inactive.
  ///
  /// What matters instead is that the platform can transfer a ride's fare to
  /// them, and that Stripe can pay their balance out to a bank account. Both
  /// are required: transfers alone means the money cannot reach their bank,
  /// and payouts alone means it can never reach their Stripe balance.
  bool get canReceivePayouts =>
      payoutsEnabled && (capabilities['transfers'] ?? '') == 'active';

  factory StripeAccount.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw FormatException('Stripe account response had no id: $json');
    }

    final capabilities = <String, String>{};
    final rawCapabilities = json['capabilities'];
    if (rawCapabilities is Map) {
      rawCapabilities.forEach((key, value) {
        if (value != null) capabilities[key.toString()] = value.toString();
      });
    }

    return StripeAccount(
      id: id,
      object: json['object']?.toString(),
      type: json['type']?.toString(),
      country: json['country']?.toString(),
      email: json['email']?.toString(),
      defaultCurrency: json['default_currency']?.toString(),
      chargesEnabled: json['charges_enabled'] == true,
      payoutsEnabled: json['payouts_enabled'] == true,
      detailsSubmitted: json['details_submitted'] == true,
      capabilities: capabilities,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {
          'id': id,
          'object': object,
          'type': type,
          'country': country,
          'email': email,
          'default_currency': defaultCurrency,
          'charges_enabled': chargesEnabled,
          'payouts_enabled': payoutsEnabled,
          'details_submitted': detailsSubmitted,
          'capabilities': capabilities,
        };
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
