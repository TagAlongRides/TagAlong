import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_repo/stripe_repo.dart';

/// The shape Accounts v2 actually returns, taken from a real test-mode
/// response, with the `account_id` the backend adds for the client.
Map<String, dynamic> v2LinkPayload({
  String created = '2026-11-15T00:21:18.000Z',
  String expiresAt = '2026-11-15T00:51:18.000Z',
}) =>
    {
      'status': 200,
      'success': true,
      'message': 'Stripe Connect Account link Url fetch successfully',
      'data': {
        'object': 'v2.core.account_link',
        'account': 'acct_1UbraBFVwQR1SZeL',
        'account_id': 'acct_1UbraBFVwQR1SZeL',
        // v2 sends ISO-8601 here; v1 sent epoch seconds.
        'created': created,
        'expires_at': expiresAt,
        'livemode': false,
        'url': 'https://connect.stripe.com/setup/e/acct_1UbraBFVwQR1SZeL/abc123',
        'use_case': {'type': 'account_onboarding'},
      },
    };

/// The Accounts v1 shape, which the app saw until the migration.
Map<String, dynamic> v1LinkPayload() => {
      'status': 200,
      'success': true,
      'message': 'Stripe Connect Account link Url fetch successfully',
      'data': {
        'object': 'account_link',
        'account_id': 'acct_1Md1cjH9gxtySUnr',
        'created': 1763164878,
        'expires_at': 1763166678,
        'url': 'https://connect.stripe.com/setup/e/acct_1Md1cjH9gxtySUnr/xyz789',
      },
    };

void main() {
  group('StripeConnectResponse', () {
    test('parses an Accounts v2 link with ISO-8601 timestamps', () {
      // The previous model typed these as int, so the first v2 link threw
      // "type 'String' is not a subtype of type 'int'".
      final response = StripeConnectResponse.fromJson(v2LinkPayload());

      expect(response.data.url, contains('connect.stripe.com'));
      expect(response.data.accountId, 'acct_1UbraBFVwQR1SZeL');
      expect(response.data.expiresAt, isA<DateTime>());
      expect(response.data.expiresAt!.toIso8601String(), startsWith('2026-11-15T00:51:18'));
    });

    test('still parses the Accounts v1 shape with epoch timestamps', () {
      final response = StripeConnectResponse.fromJson(v1LinkPayload());

      expect(response.data.accountId, 'acct_1Md1cjH9gxtySUnr');
      expect(response.data.createdAt, DateTime.utc(2025, 11, 15, 0, 1, 18));
    });

    test('falls back to the v2 account field when account_id is absent', () {
      final payload = v2LinkPayload();
      (payload['data'] as Map).remove('account_id');

      final response = StripeConnectResponse.fromJson(payload);

      expect(response.data.accountId, 'acct_1UbraBFVwQR1SZeL');
    });

    test('knows when a link has expired', () {
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
      final future = DateTime.now().toUtc().add(const Duration(minutes: 25));

      expect(
        StripeConnectResponse.fromJson(
          v2LinkPayload(expiresAt: past.toIso8601String()),
        ).data.hasExpired,
        isTrue,
      );
      expect(
        StripeConnectResponse.fromJson(
          v2LinkPayload(expiresAt: future.toIso8601String()),
        ).data.hasExpired,
        isFalse,
      );
    });

    test('a link with no expiry is not treated as expired', () {
      final payload = v2LinkPayload();
      (payload['data'] as Map).remove('expires_at');

      final response = StripeConnectResponse.fromJson(payload);

      expect(response.data.expiresAt, isNull);
      expect(response.data.hasExpired, isFalse);
    });

    test('a link with no url fails loudly', () {
      final payload = v2LinkPayload();
      (payload['data'] as Map).remove('url');

      expect(
        () => StripeConnectResponse.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('a link with no account id fails loudly', () {
      final payload = v2LinkPayload();
      (payload['data'] as Map)
        ..remove('account_id')
        ..remove('account');

      expect(
        () => StripeConnectResponse.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('an envelope with no data object fails loudly', () {
      expect(
        () => StripeConnectResponse.fromJson({
          'status': 500,
          'success': false,
          'message': 'Something went wrong',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('an unrecognised timestamp is dropped rather than thrown on', () {
      final response =
          StripeConnectResponse.fromJson(v2LinkPayload(created: 'not a date'));

      expect(response.data.createdAt, isNull);
      expect(response.data.url, isNotEmpty);
    });
  });
}
