import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_repo/stripe_repo.dart';

/// A freshly created Express account, shaped the way Stripe actually returns
/// one: no branding icon, no `card_issuing` settings block, capabilities still
/// pending, and a scattering of nulls across the optional fields.
///
/// The previous model declared all of these `required` and non-nullable, so
/// parsing this threw "type 'Null' is not a subtype of type 'String'" *after*
/// Stripe had already created the account - the driver saw a failure, the id
/// was never saved, and the next retry created another orphan account.
Map<String, dynamic> freshAccountPayload() => {
      'status': 200,
      'success': true,
      'message': 'Account Created Successfully',
      'data': {
        'id': 'acct_1NewAccount',
        'object': 'account',
        'business_profile': {
          'mcc': '4789',
          'name': null,
          'product_description': 'Providing rides to other users via the TagAlong app',
          'support_address': null,
          'support_email': null,
          'support_phone': null,
          'support_url': null,
          'url': null,
        },
        'business_type': 'individual',
        'capabilities': {'card_payments': 'inactive', 'transfers': 'inactive'},
        'charges_enabled': false,
        'country': 'US',
        'created': 1763164421,
        'default_currency': 'usd',
        'details_submitted': false,
        'email': 'driver@example.com',
        'external_accounts': {
          'object': 'list',
          'data': [],
          'has_more': false,
          'total_count': 0,
          'url': '/v1/accounts/acct_1NewAccount/external_accounts',
        },
        'metadata': {},
        'payouts_enabled': false,
        'settings': {
          'bacs_debit_payments': {},
          // icon and logo are both null on a brand new account
          'branding': {'icon': null, 'logo': null, 'primary_color': null, 'secondary_color': null},
          // `card_issuing` is omitted entirely for accounts without issuing
          'dashboard': {'display_name': null, 'timezone': 'Etc/UTC'},
          'payments': {
            'statement_descriptor': null,
            'statement_descriptor_kana': null,
            'statement_descriptor_kanji': null,
          },
          'payouts': {
            'debit_negative_balances': true,
            'schedule': {'delay_days': 2, 'interval': 'manual'},
            'statement_descriptor': null,
          },
          'sepa_debit_payments': {},
        },
        'tos_acceptance': {'date': null, 'ip': null, 'user_agent': null},
        'type': 'express',
      },
    };

void main() {
  group('StripeAccountCreateResponse', () {
    test('parses a freshly created Express account without throwing', () {
      final response = StripeAccountCreateResponse.fromJson(freshAccountPayload());

      expect(response.data.id, 'acct_1NewAccount');
      expect(response.status, 200);
      expect(response.success, isTrue);
    });

    test('an unverified account does not read as ready to take money', () {
      final response = StripeAccountCreateResponse.fromJson(freshAccountPayload());

      // chargesEnabled drives DriverData.isStripeActive, so the safe default
      // for a missing or false value is "not active".
      expect(response.data.chargesEnabled, isFalse);
      expect(response.data.payoutsEnabled, isFalse);
      expect(response.data.detailsSubmitted, isFalse);
    });

    test('missing optional fields are tolerated, id and charges still read', () {
      final response = StripeAccountCreateResponse.fromJson({
        'status': 200,
        'success': true,
        'message': 'Account Details',
        'data': {'id': 'acct_Minimal', 'charges_enabled': true},
      });

      expect(response.data.id, 'acct_Minimal');
      expect(response.data.chargesEnabled, isTrue);
      expect(response.data.capabilities, isEmpty);
      expect(response.data.email, isNull);
    });

    test('capability statuses are exposed when present', () {
      final response = StripeAccountCreateResponse.fromJson(freshAccountPayload());

      expect(response.data.capabilities['transfers'], 'inactive');
      expect(response.data.capabilities['card_payments'], 'inactive');
    });

    test('a response with no id fails loudly rather than silently', () {
      // Without an id there is nothing to save against the driver, so this
      // must throw something readable instead of a TypeError from a cast.
      expect(
        () => StripeAccountCreateResponse.fromJson({
          'status': 200,
          'success': true,
          'data': {'object': 'account'},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('an envelope with no data object fails loudly', () {
      expect(
        () => StripeAccountCreateResponse.fromJson({
          'status': 500,
          'success': false,
          'message': 'Something went wrong',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('a recipient-only account is not payable before onboarding', () {
      final response = StripeAccountCreateResponse.fromJson(
          v2AccountThroughV1Endpoint(payoutsEnabled: false, transfers: 'inactive'));

      expect(response.data.canReceivePayouts, isFalse);
    });

    test('a fully onboarded recipient account is payable', () {
      final response = StripeAccountCreateResponse.fromJson(
          v2AccountThroughV1Endpoint(payoutsEnabled: true, transfers: 'active'));

      // charges_enabled stays false forever on a recipient-only account, which
      // is exactly why readiness must not be read from it.
      expect(response.data.chargesEnabled, isFalse);
      expect(response.data.canReceivePayouts, isTrue);
    });

    test('transfers alone is not enough to pay a driver', () {
      final response = StripeAccountCreateResponse.fromJson(
          v2AccountThroughV1Endpoint(payoutsEnabled: false, transfers: 'active'));

      expect(response.data.canReceivePayouts, isFalse);
    });

    test('payouts alone is not enough either', () {
      final response = StripeAccountCreateResponse.fromJson(
          v2AccountThroughV1Endpoint(payoutsEnabled: true, transfers: 'inactive'));

      expect(response.data.canReceivePayouts, isFalse);
    });

    test('a missing transfers capability is not payable', () {
      final response = StripeAccountCreateResponse.fromJson({
        'status': 200,
        'success': true,
        'data': {'id': 'acct_X', 'payouts_enabled': true},
      });

      expect(response.data.canReceivePayouts, isFalse);
    });

    test('the raw payload is kept for debugging', () {
      final response = StripeAccountCreateResponse.fromJson(freshAccountPayload());

      expect(response.data.raw['type'], 'express');
      expect((response.data.raw['settings'] as Map)['branding'], isA<Map>());
    });
  });
}

/// What `GET /v1/accounts/{id}` actually returned for a recipient-only
/// Accounts v2 driver account, before onboarding was completed. Taken from a
/// real test-mode response.
Map<String, dynamic> v2AccountThroughV1Endpoint({
  required bool payoutsEnabled,
  required String transfers,
}) =>
    {
      'status': 200,
      'success': true,
      'message': 'Account Details',
      'data': {
        'id': 'acct_1UbraBFVwQR1SZeL',
        'object': 'account',
        // false even after onboarding: a recipient-only account has no
        // merchant configuration and cannot accept card payments at all.
        'charges_enabled': false,
        'payouts_enabled': payoutsEnabled,
        'details_submitted': payoutsEnabled,
        'type': 'none',
        'capabilities': {'transfers': transfers},
        'settings': {
          'branding': {'icon': null, 'logo': null},
        },
      },
    };

