import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_repo/stripe_repo.dart';

Map<String, dynamic> card(String id) => {
      'id': id,
      'object': 'payment_method',
      'billing_details': {'email': 'j@vt.edu', 'name': null, 'phone': null},
      'card': {
        'brand': 'visa',
        'checks': {'address_line1_check': null, 'address_postal_code_check': 'pass', 'cvc_check': 'pass'},
        'country': 'US',
        'exp_month': 4,
        'exp_year': 2028,
        'fingerprint': 'fp_123',
        'funding': 'credit',
        'generated_from': null,
        'last4': '4242',
        'networks': {'available': ['visa'], 'preferred': null},
        'three_d_secure_usage': {'supported': true},
        'wallet': null,
      },
      'created': 1763164878,
      'customer': 'cus_a',
      'livemode': false,
      'metadata': {},
      'type': 'card',
    };

/// Round-tripped through JSON so nested maps have the types a real response has.
Map<String, dynamic> envelope(Map<String, dynamic> data) => jsonDecode(jsonEncode(
    {'status': 200, 'success': true, 'message': 'Payment method fetched Successfully', 'data': data}));

void main() {
  test('the me/paymentMethods list carries the default card id', () {
    final response = StripePaymentMethodResponse.fromJson(envelope({
      'object': 'list',
      'data': [card('pm_1'), card('pm_2')],
      'has_more': false,
      'url': '/v1/payment_methods',
      'default_payment_method': 'pm_2',
    }));
    expect(response.data.data.map((c) => c.id), ['pm_1', 'pm_2']);
    expect(response.data.defaultPaymentMethod, 'pm_2');
  });

  test('the older list, or no default, reads as null', () {
    final older = StripePaymentMethodResponse.fromJson(envelope({
      'object': 'list',
      'data': [card('pm_1')],
      'has_more': false,
      'url': '/v1/payment_methods',
    }));
    expect(older.data.defaultPaymentMethod, isNull);

    final none = StripePaymentMethodResponse.fromJson(envelope({
      'object': 'list',
      'data': <Map<String, dynamic>>[],
      'has_more': false,
      'url': '/v1/payment_methods',
      'default_payment_method': null,
    }));
    expect(none.data.defaultPaymentMethod, isNull);
    expect(none.data.data, isEmpty);
  });
}
