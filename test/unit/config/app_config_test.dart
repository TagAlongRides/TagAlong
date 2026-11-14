import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// These assert the defaults compiled into a normal build. Run with
/// `--dart-define=...` and the overridden ones change, which is the point of
/// routing every value through String.fromEnvironment.
void main() {
  test('API points at the api Cloud Function, not the retired backend', () {
    expect(AppConfig.apiBaseUrl, endsWith('/api'));
    // The retired backend was the `cloudfunction` export; match the path
    // segment, not the substring, since the host is `cloudfunctions.net`.
    expect(AppConfig.apiBaseUrl, isNot(endsWith('/cloudfunction')));
    expect(AppConfig.apiVersion, '/v1/');
  });

  test('only a publishable Stripe key is ever compiled into the client', () {
    expect(AppConfig.stripePublishableKey, startsWith('pk_'));
    expect(AppConfig.stripePublishableKey, isNot(startsWith('sk_')));
  });

  test('Google sign-in has a server client id', () {
    expect(AppConfig.googleServerClientId, endsWith('.apps.googleusercontent.com'));
    expect(AppConfig.googleServerClientId, isNotEmpty);
  });

  test('legacy top-level constants track AppConfig', () {
    expect(baseUrl, AppConfig.apiBaseUrl);
    expect(apiVersion, AppConfig.apiVersion);
    expect(stripeConnectReturnUrl, AppConfig.stripeConnectReturnUrl);
    expect(stripeConnectRefreshUrl, AppConfig.stripeConnectRefreshUrl);
  });
}
