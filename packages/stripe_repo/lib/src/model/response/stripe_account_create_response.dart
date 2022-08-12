// To parse this JSON data, do
//
//     final stripeAccountCreateResponse = stripeAccountCreateResponseFromJson(jsonString);

import 'dart:convert';

StripeAccountCreateResponse stripeAccountCreateResponseFromJson(String str) =>
    StripeAccountCreateResponse.fromJson(json.decode(str));

String stripeAccountCreateResponseToJson(StripeAccountCreateResponse data) =>
    json.encode(data.toJson());

class StripeAccountCreateResponse {
  StripeAccountCreateResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final _Data data;

  factory StripeAccountCreateResponse.fromJson(Map<String, dynamic> json) =>
      StripeAccountCreateResponse(
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
    required this.businessProfile,
    required this.businessType,
    required this.capabilities,
    required this.chargesEnabled,
    required this.country,
    required this.created,
    required this.defaultCurrency,
    required this.detailsSubmitted,
    required this.email,
    required this.externalAccounts,
    required this.metadata,
    required this.payoutsEnabled,
    required this.settings,
    required this.tosAcceptance,
    required this.type,
  });

  final String id;
  final String object;
  final BusinessProfile businessProfile;
  final dynamic businessType;
  final Capabilities capabilities;
  final bool chargesEnabled;
  final String country;
  final int created;
  final String defaultCurrency;
  final bool detailsSubmitted;
  final String email;
  final ExternalAccounts externalAccounts;
  final Metadata metadata;
  final bool payoutsEnabled;
  final Settings settings;
  final DataTosAcceptance tosAcceptance;
  final String type;

  factory _Data.fromJson(Map<String, dynamic> json) => _Data(
        id: json["id"],
        object: json["object"],
        businessProfile: BusinessProfile.fromJson(json["business_profile"]),
        businessType: json["business_type"],
        capabilities: Capabilities.fromJson(json["capabilities"]),
        chargesEnabled: json["charges_enabled"],
        country: json["country"],
        created: json["created"],
        defaultCurrency: json["default_currency"],
        detailsSubmitted: json["details_submitted"],
        email: json["email"],
        externalAccounts: ExternalAccounts.fromJson(json["external_accounts"]),
        metadata: Metadata.fromJson(json["metadata"]),
        payoutsEnabled: json["payouts_enabled"],
        settings: Settings.fromJson(json["settings"]),
        tosAcceptance: DataTosAcceptance.fromJson(json["tos_acceptance"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "business_profile": businessProfile.toJson(),
        "business_type": businessType,
        "capabilities": capabilities.toJson(),
        "charges_enabled": chargesEnabled,
        "country": country,
        "created": created,
        "default_currency": defaultCurrency,
        "details_submitted": detailsSubmitted,
        "email": email,
        "external_accounts": externalAccounts.toJson(),
        "metadata": metadata.toJson(),
        "payouts_enabled": payoutsEnabled,
        "settings": settings.toJson(),
        "tos_acceptance": tosAcceptance.toJson(),
        "type": type,
      };
}

class BusinessProfile {
  BusinessProfile({
    required this.mcc,
    required this.name,
    required this.productDescription,
    required this.supportAddress,
    required this.supportEmail,
    required this.supportPhone,
    required this.supportUrl,
    required this.url,
  });

  final dynamic mcc;
  final dynamic name;
  final dynamic productDescription;
  final dynamic supportAddress;
  final dynamic supportEmail;
  final dynamic supportPhone;
  final dynamic supportUrl;
  final dynamic url;

  factory BusinessProfile.fromJson(Map<String, dynamic> json) =>
      BusinessProfile(
        mcc: json["mcc"],
        name: json["name"],
        productDescription: json["product_description"],
        supportAddress: json["support_address"],
        supportEmail: json["support_email"],
        supportPhone: json["support_phone"],
        supportUrl: json["support_url"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "mcc": mcc,
        "name": name,
        "product_description": productDescription,
        "support_address": supportAddress,
        "support_email": supportEmail,
        "support_phone": supportPhone,
        "support_url": supportUrl,
        "url": url,
      };
}

class Capabilities {
  Capabilities({
    required this.cardPayments,
    required this.transfers,
  });

  final String cardPayments;
  final String transfers;

  factory Capabilities.fromJson(Map<String, dynamic> json) => Capabilities(
        cardPayments: json["card_payments"],
        transfers: json["transfers"],
      );

  Map<String, dynamic> toJson() => {
        "card_payments": cardPayments,
        "transfers": transfers,
      };
}

class ExternalAccounts {
  ExternalAccounts({
    required this.object,
    required this.data,
    required this.hasMore,
    required this.totalCount,
    required this.url,
  });

  final String object;
  final List<dynamic> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory ExternalAccounts.fromJson(Map<String, dynamic> json) =>
      ExternalAccounts(
        object: json["object"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
        hasMore: json["has_more"],
        totalCount: json["total_count"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x)),
        "has_more": hasMore,
        "total_count": totalCount,
        "url": url,
      };
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}

class Settings {
  Settings({
    required this.bacsDebitPayments,
    required this.branding,
    required this.cardIssuing,
    required this.cardPayments,
    required this.dashboard,
    required this.payments,
    required this.payouts,
    required this.sepaDebitPayments,
  });

  final Metadata bacsDebitPayments;
  final Branding branding;
  final CardIssuing cardIssuing;
  final CardPayments cardPayments;
  final Dashboard dashboard;
  final Payments payments;
  final Payouts payouts;
  final Metadata sepaDebitPayments;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        bacsDebitPayments: Metadata.fromJson(json["bacs_debit_payments"]),
        branding: Branding.fromJson(json["branding"]),
        cardIssuing: CardIssuing.fromJson(json["card_issuing"]),
        cardPayments: CardPayments.fromJson(json["card_payments"]),
        dashboard: Dashboard.fromJson(json["dashboard"]),
        payments: Payments.fromJson(json["payments"]),
        payouts: Payouts.fromJson(json["payouts"]),
        sepaDebitPayments: Metadata.fromJson(json["sepa_debit_payments"]),
      );

  Map<String, dynamic> toJson() => {
        "bacs_debit_payments": bacsDebitPayments.toJson(),
        "branding": branding.toJson(),
        "card_issuing": cardIssuing.toJson(),
        "card_payments": cardPayments.toJson(),
        "dashboard": dashboard.toJson(),
        "payments": payments.toJson(),
        "payouts": payouts.toJson(),
        "sepa_debit_payments": sepaDebitPayments.toJson(),
      };
}

class Branding {
  Branding({
    required this.icon,
    required this.logo,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String icon;
  final dynamic logo;
  final String primaryColor;
  final String secondaryColor;

  factory Branding.fromJson(Map<String, dynamic> json) => Branding(
        icon: json["icon"],
        logo: json["logo"],
        primaryColor: json["primary_color"],
        secondaryColor: json["secondary_color"],
      );

  Map<String, dynamic> toJson() => {
        "icon": icon,
        "logo": logo,
        "primary_color": primaryColor,
        "secondary_color": secondaryColor,
      };
}

class CardIssuing {
  CardIssuing({
    required this.tosAcceptance,
  });

  final CardIssuingTosAcceptance tosAcceptance;

  factory CardIssuing.fromJson(Map<String, dynamic> json) => CardIssuing(
        tosAcceptance:
            CardIssuingTosAcceptance.fromJson(json["tos_acceptance"]),
      );

  Map<String, dynamic> toJson() => {
        "tos_acceptance": tosAcceptance.toJson(),
      };
}

class CardIssuingTosAcceptance {
  CardIssuingTosAcceptance({
    required this.date,
    required this.ip,
  });

  final dynamic date;
  final dynamic ip;

  factory CardIssuingTosAcceptance.fromJson(Map<String, dynamic> json) =>
      CardIssuingTosAcceptance(
        date: json["date"],
        ip: json["ip"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "ip": ip,
      };
}

class CardPayments {
  CardPayments({
    required this.declineOn,
    required this.statementDescriptorPrefix,
    required this.statementDescriptorPrefixKanji,
    required this.statementDescriptorPrefixKana,
  });

  final DeclineOn declineOn;
  final dynamic statementDescriptorPrefix;
  final dynamic statementDescriptorPrefixKanji;
  final dynamic statementDescriptorPrefixKana;

  factory CardPayments.fromJson(Map<String, dynamic> json) => CardPayments(
        declineOn: DeclineOn.fromJson(json["decline_on"]),
        statementDescriptorPrefix: json["statement_descriptor_prefix"],
        statementDescriptorPrefixKanji:
            json["statement_descriptor_prefix_kanji"],
        statementDescriptorPrefixKana: json["statement_descriptor_prefix_kana"],
      );

  Map<String, dynamic> toJson() => {
        "decline_on": declineOn.toJson(),
        "statement_descriptor_prefix": statementDescriptorPrefix,
        "statement_descriptor_prefix_kanji": statementDescriptorPrefixKanji,
        "statement_descriptor_prefix_kana": statementDescriptorPrefixKana,
      };
}

class DeclineOn {
  DeclineOn({
    required this.avsFailure,
    required this.cvcFailure,
  });

  final bool avsFailure;
  final bool cvcFailure;

  factory DeclineOn.fromJson(Map<String, dynamic> json) => DeclineOn(
        avsFailure: json["avs_failure"],
        cvcFailure: json["cvc_failure"],
      );

  Map<String, dynamic> toJson() => {
        "avs_failure": avsFailure,
        "cvc_failure": cvcFailure,
      };
}

class Dashboard {
  Dashboard({
    required this.displayName,
    required this.timezone,
  });

  final dynamic displayName;
  final String timezone;

  factory Dashboard.fromJson(Map<String, dynamic> json) => Dashboard(
        displayName: json["display_name"],
        timezone: json["timezone"],
      );

  Map<String, dynamic> toJson() => {
        "display_name": displayName,
        "timezone": timezone,
      };
}

class Payments {
  Payments({
    required this.statementDescriptor,
    required this.statementDescriptorKana,
    required this.statementDescriptorKanji,
  });

  final dynamic statementDescriptor;
  final dynamic statementDescriptorKana;
  final dynamic statementDescriptorKanji;

  factory Payments.fromJson(Map<String, dynamic> json) => Payments(
        statementDescriptor: json["statement_descriptor"],
        statementDescriptorKana: json["statement_descriptor_kana"],
        statementDescriptorKanji: json["statement_descriptor_kanji"],
      );

  Map<String, dynamic> toJson() => {
        "statement_descriptor": statementDescriptor,
        "statement_descriptor_kana": statementDescriptorKana,
        "statement_descriptor_kanji": statementDescriptorKanji,
      };
}

class Payouts {
  Payouts({
    required this.debitNegativeBalances,
    required this.schedule,
    required this.statementDescriptor,
  });

  final bool debitNegativeBalances;
  final Schedule schedule;
  final dynamic statementDescriptor;

  factory Payouts.fromJson(Map<String, dynamic> json) => Payouts(
        debitNegativeBalances: json["debit_negative_balances"],
        schedule: Schedule.fromJson(json["schedule"]),
        statementDescriptor: json["statement_descriptor"],
      );

  Map<String, dynamic> toJson() => {
        "debit_negative_balances": debitNegativeBalances,
        "schedule": schedule.toJson(),
        "statement_descriptor": statementDescriptor,
      };
}

class Schedule {
  Schedule({
    required this.delayDays,
    required this.interval,
  });

  final int delayDays;
  final String interval;

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        delayDays: json["delay_days"],
        interval: json["interval"],
      );

  Map<String, dynamic> toJson() => {
        "delay_days": delayDays,
        "interval": interval,
      };
}

class DataTosAcceptance {
  DataTosAcceptance({
    required this.date,
    required this.ip,
    required this.userAgent,
  });

  final dynamic date;
  final dynamic ip;
  final dynamic userAgent;

  factory DataTosAcceptance.fromJson(Map<String, dynamic> json) =>
      DataTosAcceptance(
        date: json["date"],
        ip: json["ip"],
        userAgent: json["user_agent"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "ip": ip,
        "user_agent": userAgent,
      };
}
