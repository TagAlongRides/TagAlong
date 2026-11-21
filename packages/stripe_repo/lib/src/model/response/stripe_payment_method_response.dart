// To parse this JSON data, do
//
//     final stripePaymentMethodResponse = stripePaymentMethodResponseFromJson(jsonString);

import 'dart:convert';

StripePaymentMethodResponse stripePaymentMethodResponseFromJson(String str) =>
    StripePaymentMethodResponse.fromJson(json.decode(str));

String stripePaymentMethodResponseToJson(StripePaymentMethodResponse data) =>
    json.encode(data.toJson());

class StripePaymentMethodResponse {
  StripePaymentMethodResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final _Data data;

  factory StripePaymentMethodResponse.fromJson(Map<String, dynamic> json) =>
      StripePaymentMethodResponse(
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
    required this.data,
    required this.hasMore,
    required this.url,
    this.defaultPaymentMethod,
  });

  final String object;
  final List<PaymentMethod> data;
  final bool hasMore;
  final String url;

  /// Id of the customer's default card. Only the `me/paymentMethods` route
  /// sends it; null when there is no default or the older route answered.
  final String? defaultPaymentMethod;

  factory _Data.fromJson(Map<String, dynamic> json) => _Data(
        object: json["object"],
        data: List<PaymentMethod>.from(
            json["data"].map((x) => PaymentMethod.fromJson(x))),
        hasMore: json["has_more"],
        url: json["url"],
        defaultPaymentMethod: json["default_payment_method"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "has_more": hasMore,
        "url": url,
        if (defaultPaymentMethod != null) "default_payment_method": defaultPaymentMethod,
      };
}

class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.object,
    required this.billingDetails,
    required this.card,
    required this.created,
    required this.customer,
    required this.livemode,
    required this.metadata,
    required this.type,
  });

  final String id;
  final String object;
  final _BillingDetails billingDetails;
  final Card card;
  final int created;
  final String customer;
  final bool livemode;
  final _Metadata metadata;
  final String type;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        object: json["object"],
        billingDetails: _BillingDetails.fromJson(json["billing_details"]),
        card: Card.fromJson(json["card"]),
        created: json["created"],
        customer: json["customer"],
        livemode: json["livemode"],
        metadata: _Metadata.fromJson(json["metadata"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "billing_details": billingDetails.toJson(),
        "card": card.toJson(),
        "created": created,
        "customer": customer,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "type": type,
      };
}

class _BillingDetails {
  _BillingDetails({
    // required this.address,
    required this.email,
    required this.name,
    required this.phone,
  });

  // final Address address;
  final String? email;
  final dynamic name;
  final dynamic phone;

  factory _BillingDetails.fromJson(Map<String, dynamic> json) =>
      _BillingDetails(
        // address: Address.fromJson(json["address"]),
        email: json["email"] == null ? null : json["email"],
        name: json["name"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        // "address": address.toJson(),
        "email": email == null ? null : email,
        "name": name,
        "phone": phone,
      };
}

// class Address {
//   Address({
//     required this.city,
//     required this.country,
//     required this.line1,
//     required this.line2,
//     required this.postalCode,
//     required this.state,
//   });

//   final dynamic city;
//   final String country;
//   final dynamic line1;
//   final dynamic line2;
//   final String postalCode;
//   final dynamic state;

//   factory Address.fromJson(Map<String, dynamic> json) => Address(
//         city: json["city"],
//         country: json["country"] == null ? null : json["country"],
//         line1: json["line1"],
//         line2: json["line2"],
//         postalCode: json["postal_code"] == null ? null : json["postal_code"],
//         state: json["state"],
//       );

//   Map<String, dynamic> toJson() => {
//         "city": city,
//         "country": country == null ? null : country,
//         "line1": line1,
//         "line2": line2,
//         "postal_code": postalCode == null ? null : postalCode,
//         "state": state,
//       };
// }

class Card {
  Card({
    required this.brand,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.fingerprint,
    required this.funding,
    required this.generatedFrom,
    required this.last4,
    required this.networks,
    required this.threeDSecureUsage,
    required this.wallet,
  });

  final String brand;
  final String country;
  final int expMonth;
  final int expYear;
  final String fingerprint;
  final String funding;
  final dynamic generatedFrom;
  final String last4;
  final Networks networks;
  final ThreeDSecureUsage threeDSecureUsage;
  final dynamic wallet;

  factory Card.fromJson(Map<String, dynamic> json) => Card(
        brand: json["brand"],
        country: json["country"],
        expMonth: json["exp_month"],
        expYear: json["exp_year"],
        fingerprint: json["fingerprint"],
        funding: json["funding"],
        generatedFrom: json["generated_from"],
        last4: json["last4"],
        networks: Networks.fromJson(json["networks"]),
        threeDSecureUsage:
            ThreeDSecureUsage.fromJson(json["three_d_secure_usage"]),
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
        "brand": brand,
        "country": country,
        "exp_month": expMonth,
        "exp_year": expYear,
        "fingerprint": fingerprint,
        "funding": funding,
        "generated_from": generatedFrom,
        "last4": last4,
        "networks": networks.toJson(),
        "three_d_secure_usage": threeDSecureUsage.toJson(),
        "wallet": wallet,
      };
}

class Networks {
  Networks({
    required this.available,
    required this.preferred,
  });

  final List<String> available;
  final dynamic preferred;

  factory Networks.fromJson(Map<String, dynamic> json) => Networks(
        available: List<String>.from(json["available"].map((x) => x)),
        preferred: json["preferred"],
      );

  Map<String, dynamic> toJson() => {
        "available": List<dynamic>.from(available.map((x) => x)),
        "preferred": preferred,
      };
}

class ThreeDSecureUsage {
  ThreeDSecureUsage({
    required this.supported,
  });

  final bool supported;

  factory ThreeDSecureUsage.fromJson(Map<String, dynamic> json) =>
      ThreeDSecureUsage(
        supported: json["supported"],
      );

  Map<String, dynamic> toJson() => {
        "supported": supported,
      };
}

class _Metadata {
  _Metadata();

  factory _Metadata.fromJson(Map<String, dynamic> json) => _Metadata();

  Map<String, dynamic> toJson() => {};
}
