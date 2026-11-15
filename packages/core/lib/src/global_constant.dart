/// Configuration for the TagAlong client.
///
/// ## Nothing in this file is a secret
///
/// Anything compiled into the app can be read out of the APK by anyone who
/// installs it. Publishable keys, OAuth client ids and API URLs are *designed*
/// to be public, so they live here. A real secret - a Stripe secret key, a
/// service account key, a third-party API token - must never appear in client
/// code, no matter how it is stored or obfuscated.
///
/// ## Where credentials actually go
///
/// | Kind | Home | How it is read |
/// | --- | --- | --- |
/// | Server secrets | Cloud Secret Manager | `defineSecret()` in `functions/` |
/// | Public client config | This file | `--dart-define` at build time |
///
/// To add a server secret:
/// ```
/// firebase functions:secrets:set MY_SECRET
/// ```
/// then declare it with `defineSecret('MY_SECRET')` and list it in the
/// function's `secrets:` option. It is injected at runtime and never lands in
/// the repository or the app.
///
/// ## Switching environments
///
/// Every value below can be overridden at build time without editing code:
/// ```
/// flutter build apk \
///   --dart-define=TAGALONG_API_BASE_URL=https://us-central1-my-staging.cloudfunctions.net/api \
///   --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
/// ```
class AppConfig {
  /// The TagAlong API, served by the `api` Cloud Function in `functions/`.
  ///
  /// The previous backend was the `cloudfunction` export of a Node 16
  /// codebase outside this repository, at `.../cloudfunction` + `/api/v1/`.
  /// It is still deployed, so a rollback is a `--dart-define` away.
  static const String apiBaseUrl = String.fromEnvironment(
    'TAGALONG_API_BASE_URL',
    defaultValue: 'https://us-central1-tagalong-1c5fb.cloudfunctions.net/api',
  );

  static const String apiVersion = String.fromEnvironment(
    'TAGALONG_API_VERSION',
    defaultValue: '/v1/',
  );

  /// Stripe's *publishable* key. Safe to ship; it can only create tokens, not
  /// move money. The secret key lives in Secret Manager and is used only by
  /// the Cloud Functions.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51KrmEeHOJhcBOg6eRUYQ0r274bFJuDrXl87YoDf32FiU3Koz'
        'WxYtUi5sgxBJfmw8ZvZQM9SjzWkgmYJMbnHTekEK00HyDQBaBU',
  );

  /// The project's web OAuth client, used as Google Sign-In's server client id
  /// and by Firebase to verify the resulting token.
  ///
  /// Passed explicitly rather than relying on the `default_web_client_id`
  /// resource generated from google-services.json, which silently disappears
  /// if the web client is missing from that file.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '296547975151-sssur02gulngthf4619u1ievlpl5o862.apps.googleusercontent.com',
  );

  /// Where Stripe sends a driver back to after hosted Connect onboarding.
  ///
  /// TODO: these are placeholder domains that TagAlong does not own, carried
  /// over from the original implementation. Stripe redirects drivers here when
  /// onboarding finishes, and the app watches for `returnurl` in the URL to
  /// know it is done, so a domain we control (or a deep link) is needed before
  /// release.
  static const String stripeConnectReturnUrl = String.fromEnvironment(
    'STRIPE_CONNECT_RETURN_URL',
    defaultValue: 'https://www.returnurl.com',
  );

  static const String stripeConnectRefreshUrl = String.fromEnvironment(
    'STRIPE_CONNECT_REFRESH_URL',
    defaultValue: 'https://www.refreshurl.com',
  );
}

// Kept so existing call sites keep working; prefer AppConfig for new code.
const String baseUrl = AppConfig.apiBaseUrl;
const String apiVersion = AppConfig.apiVersion;
const String stripeConnectRefreshUrl = AppConfig.stripeConnectRefreshUrl;
const String stripeConnectReturnUrl = AppConfig.stripeConnectReturnUrl;
