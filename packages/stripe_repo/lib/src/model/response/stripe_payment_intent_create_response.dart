// To parse this JSON data, do
//
//     final stripePaymentIntentCreateResponse = stripePaymentIntentCreateResponseFromJson(jsonString);

import 'dart:convert';

StripePaymentIntentCreateResponse stripePaymentIntentCreateResponseFromJson(
        String str) =>
    StripePaymentIntentCreateResponse.fromJson(json.decode(str));

String stripePaymentIntentCreateResponseToJson(
        StripePaymentIntentCreateResponse data) =>
    json.encode(data.toJson());

class StripePaymentIntentCreateResponse {
  StripePaymentIntentCreateResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
  });

  final int status;
  final bool success;
  final String message;
  final _Data data;

  factory StripePaymentIntentCreateResponse.fromJson(
          Map<String, dynamic> json) =>
      StripePaymentIntentCreateResponse(
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
    required this.amountCapturable,
    required this.amountDetails,
    required this.amountReceived,
    required this.application,
    required this.applicationFeeAmount,
    required this.automaticPaymentMethods,
    required this.canceledAt,
    required this.cancellationReason,
    required this.captureMethod,
    required this.charges,
    required this.clientSecret,
    required this.confirmationMethod,
    required this.created,
    required this.currency,
    this.customer,
    required this.description,
    required this.invoice,
    required this.lastPaymentError,
    required this.livemode,
    required this.metadata,
    required this.nextAction,
    required this.onBehalfOf,
    required this.paymentMethod,
    required this.paymentMethodOptions,
    required this.paymentMethodTypes,
    required this.processing,
    required this.receiptEmail,
    required this.review,
    required this.setupFutureUsage,
    required this.shipping,
    required this.source,
    required this.statementDescriptor,
    required this.statementDescriptorSuffix,
    required this.status,
    required this.transferData,
    required this.transferGroup,
  });

  final String id;
  final String object;
  final int amount;
  final int amountCapturable;
  final AmountDetails amountDetails;
  final int amountReceived;
  final dynamic application;
  final int? applicationFeeAmount;
  final dynamic automaticPaymentMethods;
  final dynamic canceledAt;
  final dynamic cancellationReason;
  final String captureMethod;
  final _Charges charges;
  final String clientSecret;
  final String confirmationMethod;
  final int created;
  final String currency;
  final String? customer;
  final dynamic description;
  final dynamic invoice;
  final dynamic lastPaymentError;
  final bool livemode;
  final _Metadata metadata;
  final dynamic nextAction;
  final dynamic onBehalfOf;
  final String paymentMethod;
  final _PaymentMethodOptions paymentMethodOptions;
  final List<String> paymentMethodTypes;
  final dynamic processing;
  final String receiptEmail;
  final dynamic review;
  final String setupFutureUsage;
  final dynamic shipping;
  final dynamic source;
  final dynamic statementDescriptor;
  final dynamic statementDescriptorSuffix;
  final String status;
  final DataTransferData? transferData;
  final String transferGroup;

  factory _Data.fromJson(Map<String, dynamic> json) => _Data(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        amountCapturable: json["amount_capturable"],
        amountDetails: AmountDetails.fromJson(json["amount_details"]),
        amountReceived: json["amount_received"],
        application: json["application"],
        applicationFeeAmount: json["application_fee_amount"],
        automaticPaymentMethods: json["automatic_payment_methods"],
        canceledAt: json["canceled_at"],
        cancellationReason: json["cancellation_reason"],
        captureMethod: json["capture_method"],
        charges: _Charges.fromJson(json["charges"]),
        clientSecret: json["client_secret"],
        confirmationMethod: json["confirmation_method"],
        created: json["created"],
        currency: json["currency"],
        customer: json["customer"],
        description: json["description"],
        invoice: json["invoice"],
        lastPaymentError: json["last_payment_error"],
        livemode: json["livemode"],
        metadata: _Metadata.fromJson(json["metadata"]),
        nextAction: json["next_action"],
        onBehalfOf: json["on_behalf_of"],
        paymentMethod: json["payment_method"],
        paymentMethodOptions:
            _PaymentMethodOptions.fromJson(json["payment_method_options"]),
        paymentMethodTypes:
            List<String>.from(json["payment_method_types"].map((x) => x)),
        processing: json["processing"],
        receiptEmail: json["receipt_email"],
        review: json["review"],
        setupFutureUsage: json["setup_future_usage"],
        shipping: json["shipping"],
        source: json["source"],
        statementDescriptor: json["statement_descriptor"],
        statementDescriptorSuffix: json["statement_descriptor_suffix"],
        status: json["status"],
        transferData: json["transfer_data"] == null
            ? null
            : DataTransferData.fromJson(json["transfer_data"]),
        transferGroup: json["transfer_group"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "amount_capturable": amountCapturable,
        "amount_details": amountDetails.toJson(),
        "amount_received": amountReceived,
        "application": application,
        "application_fee_amount": applicationFeeAmount,
        "automatic_payment_methods": automaticPaymentMethods,
        "canceled_at": canceledAt,
        "cancellation_reason": cancellationReason,
        "capture_method": captureMethod,
        "charges": charges.toJson(),
        "client_secret": clientSecret,
        "confirmation_method": confirmationMethod,
        "created": created,
        "currency": currency,
        "customer": customer,
        "description": description,
        "invoice": invoice,
        "last_payment_error": lastPaymentError,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "next_action": nextAction,
        "on_behalf_of": onBehalfOf,
        "payment_method": paymentMethod,
        "payment_method_options": paymentMethodOptions.toJson(),
        "payment_method_types":
            List<dynamic>.from(paymentMethodTypes.map((x) => x)),
        "processing": processing,
        "receipt_email": receiptEmail,
        "review": review,
        "setup_future_usage": setupFutureUsage,
        "shipping": shipping,
        "source": source,
        "statement_descriptor": statementDescriptor,
        "statement_descriptor_suffix": statementDescriptorSuffix,
        "status": status,
        "transfer_data": transferData?.toJson(),
        "transfer_group": transferGroup,
      };
}

class AmountDetails {
  AmountDetails({
    required this.tip,
  });

  final _Metadata tip;

  factory AmountDetails.fromJson(Map<String, dynamic> json) => AmountDetails(
        tip: _Metadata.fromJson(json["tip"]),
      );

  Map<String, dynamic> toJson() => {
        "tip": tip.toJson(),
      };
}

class _Metadata {
  _Metadata();

  factory _Metadata.fromJson(Map<String, dynamic> json) => _Metadata();

  Map<String, dynamic> toJson() => {};
}

class Datum {
  Datum({
    required this.id,
    required this.object,
    required this.amount,
    required this.amountCaptured,
    required this.amountRefunded,
    required this.application,
    required this.applicationFee,
    required this.applicationFeeAmount,
    required this.balanceTransaction,
    required this.billingDetails,
    required this.calculatedStatementDescriptor,
    required this.captured,
    required this.created,
    required this.currency,
    required this.customer,
    required this.description,
    required this.destination,
    required this.dispute,
    required this.disputed,
    required this.failureBalanceTransaction,
    required this.failureCode,
    required this.failureMessage,
    required this.fraudDetails,
    required this.invoice,
    required this.livemode,
    required this.metadata,
    required this.onBehalfOf,
    required this.order,
    required this.outcome,
    required this.paid,
    required this.paymentIntent,
    required this.paymentMethod,
    required this.paymentMethodDetails,
    required this.receiptEmail,
    required this.receiptNumber,
    required this.receiptUrl,
    required this.refunded,
    required this.refunds,
    required this.review,
    required this.shipping,
    required this.source,
    required this.sourceTransfer,
    required this.statementDescriptor,
    required this.statementDescriptorSuffix,
    required this.status,
    required this.transfer,
    required this.transferData,
    required this.transferGroup,
  });

  final String id;
  final String object;
  final int amount;
  final int amountCaptured;
  final int amountRefunded;
  final dynamic application;
  final String? applicationFee;
  final int? applicationFeeAmount;
  final String balanceTransaction;
  final _BillingDetails billingDetails;
  final String calculatedStatementDescriptor;
  final bool captured;
  final int created;
  final String currency;
  final String? customer;
  final dynamic description;
  final String? destination;
  final dynamic dispute;
  final bool disputed;
  final dynamic failureBalanceTransaction;
  final dynamic failureCode;
  final dynamic failureMessage;
  final _Metadata fraudDetails;
  final dynamic invoice;
  final bool livemode;
  final _Metadata metadata;
  final dynamic onBehalfOf;
  final dynamic order;
  final Outcome outcome;
  final bool paid;
  final String paymentIntent;
  final String paymentMethod;
  final PaymentMethodDetails paymentMethodDetails;
  final String receiptEmail;
  final dynamic receiptNumber;
  final String receiptUrl;
  final bool refunded;
  final _Charges refunds;
  final dynamic review;
  final dynamic shipping;
  final dynamic source;
  final dynamic sourceTransfer;
  final dynamic statementDescriptor;
  final dynamic statementDescriptorSuffix;
  final String status;
  final String? transfer;
  final DatumTransferData? transferData;
  final String transferGroup;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        object: json["object"],
        amount: json["amount"],
        amountCaptured: json["amount_captured"],
        amountRefunded: json["amount_refunded"],
        application: json["application"],
        applicationFee: json["application_fee"],
        applicationFeeAmount: json["application_fee_amount"],
        balanceTransaction: json["balance_transaction"],
        billingDetails: _BillingDetails.fromJson(json["billing_details"]),
        calculatedStatementDescriptor: json["calculated_statement_descriptor"],
        captured: json["captured"],
        created: json["created"],
        currency: json["currency"],
        customer: json["customer"],
        description: json["description"],
        destination: json["destination"],
        dispute: json["dispute"],
        disputed: json["disputed"],
        failureBalanceTransaction: json["failure_balance_transaction"],
        failureCode: json["failure_code"],
        failureMessage: json["failure_message"],
        fraudDetails: _Metadata.fromJson(json["fraud_details"]),
        invoice: json["invoice"],
        livemode: json["livemode"],
        metadata: _Metadata.fromJson(json["metadata"]),
        onBehalfOf: json["on_behalf_of"],
        order: json["order"],
        outcome: Outcome.fromJson(json["outcome"]),
        paid: json["paid"],
        paymentIntent: json["payment_intent"],
        paymentMethod: json["payment_method"],
        paymentMethodDetails:
            PaymentMethodDetails.fromJson(json["payment_method_details"]),
        receiptEmail: json["receipt_email"],
        receiptNumber: json["receipt_number"],
        receiptUrl: json["receipt_url"],
        refunded: json["refunded"],
        refunds: _Charges.fromJson(json["refunds"]),
        review: json["review"],
        shipping: json["shipping"],
        source: json["source"],
        sourceTransfer: json["source_transfer"],
        statementDescriptor: json["statement_descriptor"],
        statementDescriptorSuffix: json["statement_descriptor_suffix"],
        status: json["status"],
        transfer: json["transfer"],
        transferData: json["transfer_data"] == null
            ? null
            : DatumTransferData.fromJson(json["transfer_data"]),
        transferGroup: json["transfer_group"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "amount": amount,
        "amount_captured": amountCaptured,
        "amount_refunded": amountRefunded,
        "application": application,
        "application_fee": applicationFee,
        "application_fee_amount": applicationFeeAmount,
        "balance_transaction": balanceTransaction,
        "billing_details": billingDetails.toJson(),
        "calculated_statement_descriptor": calculatedStatementDescriptor,
        "captured": captured,
        "created": created,
        "currency": currency,
        "customer": customer,
        "description": description,
        "destination": destination,
        "dispute": dispute,
        "disputed": disputed,
        "failure_balance_transaction": failureBalanceTransaction,
        "failure_code": failureCode,
        "failure_message": failureMessage,
        "fraud_details": fraudDetails.toJson(),
        "invoice": invoice,
        "livemode": livemode,
        "metadata": metadata.toJson(),
        "on_behalf_of": onBehalfOf,
        "order": order,
        "outcome": outcome.toJson(),
        "paid": paid,
        "payment_intent": paymentIntent,
        "payment_method": paymentMethod,
        "payment_method_details": paymentMethodDetails.toJson(),
        "receipt_email": receiptEmail,
        "receipt_number": receiptNumber,
        "receipt_url": receiptUrl,
        "refunded": refunded,
        "refunds": refunds.toJson(),
        "review": review,
        "shipping": shipping,
        "source": source,
        "source_transfer": sourceTransfer,
        "statement_descriptor": statementDescriptor,
        "statement_descriptor_suffix": statementDescriptorSuffix,
        "status": status,
        "transfer": transfer,
        "transfer_data": transferData?.toJson(),
        "transfer_group": transferGroup,
      };
}

class _Charges {
  _Charges({
    required this.object,
    required this.data,
    required this.hasMore,
    required this.totalCount,
    required this.url,
  });

  final String object;
  final List<Datum> data;
  final bool hasMore;
  final int totalCount;
  final String url;

  factory _Charges.fromJson(Map<String, dynamic> json) => _Charges(
        object: json["object"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        hasMore: json["has_more"],
        totalCount: json["total_count"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "object": object,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "has_more": hasMore,
        "total_count": totalCount,
        "url": url,
      };
}

class _BillingDetails {
  _BillingDetails({
    required this.address,
    required this.email,
    required this.name,
    required this.phone,
  });

  final Address address;
  final dynamic email;
  final dynamic name;
  final dynamic phone;

  factory _BillingDetails.fromJson(Map<String, dynamic> json) =>
      _BillingDetails(
        address: Address.fromJson(json["address"]),
        email: json["email"],
        name: json["name"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
        "address": address.toJson(),
        "email": email,
        "name": name,
        "phone": phone,
      };
}

class Address {
  Address({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });

  final dynamic city;
  final dynamic country;
  final dynamic line1;
  final dynamic line2;
  final dynamic postalCode;
  final dynamic state;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json["city"],
        country: json["country"],
        line1: json["line1"],
        line2: json["line2"],
        postalCode: json["postal_code"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "country": country,
        "line1": line1,
        "line2": line2,
        "postal_code": postalCode,
        "state": state,
      };
}

class Outcome {
  Outcome({
    required this.networkStatus,
    required this.reason,
    required this.riskLevel,
    required this.riskScore,
    required this.sellerMessage,
    required this.type,
  });

  final String networkStatus;
  final dynamic reason;
  final String riskLevel;
  final int riskScore;
  final String sellerMessage;
  final String type;

  factory Outcome.fromJson(Map<String, dynamic> json) => Outcome(
        networkStatus: json["network_status"],
        reason: json["reason"],
        riskLevel: json["risk_level"],
        riskScore: json["risk_score"],
        sellerMessage: json["seller_message"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "network_status": networkStatus,
        "reason": reason,
        "risk_level": riskLevel,
        "risk_score": riskScore,
        "seller_message": sellerMessage,
        "type": type,
      };
}

class PaymentMethodDetails {
  PaymentMethodDetails({
    required this.card,
    required this.type,
  });

  final PaymentMethodDetailsCard card;
  final String type;

  factory PaymentMethodDetails.fromJson(Map<String, dynamic> json) =>
      PaymentMethodDetails(
        card: PaymentMethodDetailsCard.fromJson(json["card"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "card": card.toJson(),
        "type": type,
      };
}

class PaymentMethodDetailsCard {
  PaymentMethodDetailsCard({
    required this.brand,
    required this.checks,
    required this.country,
    required this.expMonth,
    required this.expYear,
    required this.fingerprint,
    required this.funding,
    required this.installments,
    required this.last4,
    required this.mandate,
    required this.network,
    required this.threeDSecure,
    required this.wallet,
  });

  final String brand;
  final Checks checks;
  final String country;
  final int expMonth;
  final int expYear;
  final String fingerprint;
  final String funding;
  final dynamic installments;
  final String last4;
  final dynamic mandate;
  final String network;
  final dynamic threeDSecure;
  final dynamic wallet;

  factory PaymentMethodDetailsCard.fromJson(Map<String, dynamic> json) =>
      PaymentMethodDetailsCard(
        brand: json["brand"],
        checks: Checks.fromJson(json["checks"]),
        country: json["country"],
        expMonth: json["exp_month"],
        expYear: json["exp_year"],
        fingerprint: json["fingerprint"],
        funding: json["funding"],
        installments: json["installments"],
        last4: json["last4"],
        mandate: json["mandate"],
        network: json["network"],
        threeDSecure: json["three_d_secure"],
        wallet: json["wallet"],
      );

  Map<String, dynamic> toJson() => {
        "brand": brand,
        "checks": checks.toJson(),
        "country": country,
        "exp_month": expMonth,
        "exp_year": expYear,
        "fingerprint": fingerprint,
        "funding": funding,
        "installments": installments,
        "last4": last4,
        "mandate": mandate,
        "network": network,
        "three_d_secure": threeDSecure,
        "wallet": wallet,
      };
}

class Checks {
  Checks({
    required this.addressLine1Check,
    required this.addressPostalCodeCheck,
    required this.cvcCheck,
  });

  final dynamic addressLine1Check;
  final dynamic addressPostalCodeCheck;
  final dynamic cvcCheck;

  factory Checks.fromJson(Map<String, dynamic> json) => Checks(
        addressLine1Check: json["address_line1_check"],
        addressPostalCodeCheck: json["address_postal_code_check"],
        cvcCheck: json["cvc_check"],
      );

  Map<String, dynamic> toJson() => {
        "address_line1_check": addressLine1Check,
        "address_postal_code_check": addressPostalCodeCheck,
        "cvc_check": cvcCheck,
      };
}

class DatumTransferData {
  DatumTransferData({
    required this.amount,
    required this.destination,
  });

  final dynamic amount;
  final String destination;

  factory DatumTransferData.fromJson(Map<String, dynamic> json) =>
      DatumTransferData(
        amount: json["amount"],
        destination: json["destination"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "destination": destination,
      };
}

class _PaymentMethodOptions {
  _PaymentMethodOptions({
    required this.card,
  });

  final PaymentMethodOptionsCard card;

  factory _PaymentMethodOptions.fromJson(Map<String, dynamic> json) =>
      _PaymentMethodOptions(
        card: PaymentMethodOptionsCard.fromJson(json["card"]),
      );

  Map<String, dynamic> toJson() => {
        "card": card.toJson(),
      };
}

class PaymentMethodOptionsCard {
  PaymentMethodOptionsCard({
    required this.installments,
    required this.mandateOptions,
    required this.network,
    required this.requestThreeDSecure,
  });

  final dynamic installments;
  final dynamic mandateOptions;
  final dynamic network;
  final String requestThreeDSecure;

  factory PaymentMethodOptionsCard.fromJson(Map<String, dynamic> json) =>
      PaymentMethodOptionsCard(
        installments: json["installments"],
        mandateOptions: json["mandate_options"],
        network: json["network"],
        requestThreeDSecure: json["request_three_d_secure"],
      );

  Map<String, dynamic> toJson() => {
        "installments": installments,
        "mandate_options": mandateOptions,
        "network": network,
        "request_three_d_secure": requestThreeDSecure,
      };
}

class DataTransferData {
  DataTransferData({
    required this.destination,
  });

  final String destination;

  factory DataTransferData.fromJson(Map<String, dynamic> json) =>
      DataTransferData(
        destination: json["destination"],
      );

  Map<String, dynamic> toJson() => {
        "destination": destination,
      };
}
