# Where credentials go

Two homes, decided by one question: **can anyone who installs the app be
allowed to read this?**

| Kind | Examples | Home | Read by |
| --- | --- | --- | --- |
| **Secret** | Stripe secret key, service account keys, webhook signing secrets, third-party API tokens | **Cloud Secret Manager** | `functions/` only |
| **Public config** | Stripe *publishable* key, OAuth client ids, API base URL | `packages/core/lib/src/global_constant.dart` (`AppConfig`) | the app |

Anything compiled into the app can be extracted from the APK. Obfuscation,
encryption at rest and Remote Config do not change that — whatever the app can
read at runtime, so can its user. There is no safe way to put a secret in a
mobile client, so secrets stay server-side and the app reaches them only
through an authenticated API call.

## Adding a server secret

```bash
firebase functions:secrets:set MY_SECRET
```

Declare it and attach it to whichever functions need it:

```js
const mySecret = defineSecret("MY_SECRET");
exports.api = onRequest({secrets: [mySecret]}, app);
```

It is injected at runtime. It never enters the repository, the app, or
`firebase.json`. `functions.config()` no longer exists — it was retired with
the Node 18 runtime.

## Adding public client config

Add a field to `AppConfig` using `String.fromEnvironment` with a default, so
it can be overridden per environment without editing code:

```dart
static const String myValue = String.fromEnvironment(
  'MY_VALUE',
  defaultValue: 'the-production-value',
);
```

## Switching environments

```bash
flutter build apk \
  --dart-define=TAGALONG_API_BASE_URL=https://us-central1-staging.cloudfunctions.net/api \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

`app_config_test.dart` asserts the defaults, including that the compiled Stripe
key is a `pk_` and never an `sk_`.

## If a secret leaks

Rotate first, then clean up. Removing a secret from `HEAD` does not remove it
from git history, and history rewriting is rarely worth the disruption — a
revoked credential is harmless wherever it is.

Known leaked credentials in this repository's history, all of which should be
revoked at their provider:

- the carmakemodeldb API token (`car_make_model_service.dart`, removed in the
  working tree, still in history from `0a57830`)
- the Stripe secret key and a service account key, both bundled into the
  deployed Node 16 function source that predates this repository
