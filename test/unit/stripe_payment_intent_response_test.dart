import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_repo/stripe_repo.dart';

/// A succeeded destination charge as a current API version returns it: a
/// `latest_charge` id, no `charges` list, and nulls across the optional
/// fields. The previous model declared ~60 of these `required` and
/// non-nullable, and read the charge id from `charges.data[0].id`.
Map<String, dynamic> succeededIntent({
  Object? latestCharge = 'ch_3QxLatest',
  Map<String, dynamic>? charges,
}) =>
    {
      'status': 200,
      'success': true,
      'message': 'Payment Intent Created Successfully',
      'data': {
        'id': 'pi_3QxAbCdEf',
        'object': 'payment_intent',
        'amount': 2100,
        'currency': 'usd',
        'status': 'succeeded',
        'client_secret': 'pi_3QxAbCdEf_secret_xyz',
        'latest_charge': latestCharge,
        if (charges != null) 'charges': charges,
        'application_fee_amount': 525,
        'transfer_data': {'destination': 'acct_driver'},
        // All of these come back null on a straightforward success.
        'canceled_at': null,
        'cancellation_reason': null,
        'description': null,
        'invoice': null,
        'last_payment_error': null,
        'next_action': null,
        'on_behalf_of': null,
        'receipt_email': null,
        'statement_descriptor': null,
        'transfer_group': null,
      },
    };

void main() {
  group('StripePaymentIntentCreateResponse', () {
    test('parses a succeeded intent full of nulls', () {
      final response = StripePaymentIntentCreateResponse.fromJson(succeededIntent());

      expect(response.data.id, 'pi_3QxAbCdEf');
      expect(response.data.status, 'succeeded');
      expect(response.data.amount, 2100);
      expect(response.data.clientSecret, 'pi_3QxAbCdEf_secret_xyz');
    });

    test('reads the charge id from latest_charge', () {
      // `charges` was removed from PaymentIntent in API version 2022-11-15.
      // Reading it was why a booking could not be recorded at all.
      final response = StripePaymentIntentCreateResponse.fromJson(succeededIntent());

      expect(response.data.latestChargeId, 'ch_3QxLatest');
    });

    test('handles an expanded latest_charge object', () {
      final response = StripePaymentIntentCreateResponse.fromJson(
          succeededIntent(latestCharge: {'id': 'ch_expanded', 'object': 'charge'}));

      expect(response.data.latestChargeId, 'ch_expanded');
    });

    test('falls back to the pre-2022 charges list', () {
      final response = StripePaymentIntentCreateResponse.fromJson(succeededIntent(
        latestCharge: null,
        charges: {
          'object': 'list',
          'data': [
            {'id': 'ch_legacy', 'object': 'charge'}
          ],
        },
      ));

      expect(response.data.latestChargeId, 'ch_legacy');
    });

    test('a settled intent with no charge id does not throw', () {
      // The passenger has already paid by this point. Losing the booking over
      // a missing id would be far worse than recording it without one.
      final response = StripePaymentIntentCreateResponse.fromJson(
          succeededIntent(latestCharge: null));

      expect(response.data.latestChargeId, isNull);
      expect(response.data.id, 'pi_3QxAbCdEf');
      expect(response.data.status, 'succeeded');
    });

    test('an intent awaiting 3D Secure keeps its client secret', () {
      final payload = succeededIntent(latestCharge: null);
      (payload['data'] as Map)['status'] = 'requires_action';

      final response = StripePaymentIntentCreateResponse.fromJson(payload);

      expect(response.data.status, 'requires_action');
      expect(response.data.clientSecret, isNotEmpty);
    });

    test('an intent with no id fails loudly', () {
      final payload = succeededIntent();
      (payload['data'] as Map).remove('id');

      expect(
        () => StripePaymentIntentCreateResponse.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('an intent with no status fails loudly', () {
      // The booking flow branches on status, so a response without one cannot
      // be acted on safely either way.
      final payload = succeededIntent();
      (payload['data'] as Map).remove('status');

      expect(
        () => StripePaymentIntentCreateResponse.fromJson(payload),
        throwsA(isA<FormatException>()),
      );
    });

    test('an envelope with no data object fails loudly', () {
      expect(
        () => StripePaymentIntentCreateResponse.fromJson({
          'status': 500,
          'success': false,
          'message': 'Something went wrong',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('keeps the raw payload for debugging', () {
      final response = StripePaymentIntentCreateResponse.fromJson(succeededIntent());

      expect(response.data.raw['application_fee_amount'], 525);
      expect((response.data.raw['transfer_data'] as Map)['destination'], 'acct_driver');
    });
  });
}
