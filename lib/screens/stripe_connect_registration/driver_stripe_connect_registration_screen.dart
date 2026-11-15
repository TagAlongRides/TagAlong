import 'dart:async';
import 'dart:developer';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/screens/ride_board_screen.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DriverStripeConnectRegistrationScreen extends StatefulWidget {
  const DriverStripeConnectRegistrationScreen({Key? key}) : super(key: key);
  static const routeName = '/stripe-registration';

  @override
  State<DriverStripeConnectRegistrationScreen> createState() => _DriverStripeConnectRegistrationScreenState();
}

class _DriverStripeConnectRegistrationScreenState extends State<DriverStripeConnectRegistrationScreen> {
  StripeConnectResponse? _connectResponse;

  TagAlongUser? _tagAlongUser;
  late TagAlongUserViewModel _tagAlongUserViewModel;

  /// Built once the Stripe onboarding URL comes back, since webview_flutter 4
  /// takes the URL through the controller rather than the widget.
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchStripeConnectUrl();
    });
  }

  /// Points the web view at Stripe's hosted onboarding flow and watches for the
  /// return URL that means the driver finished.
  void _loadConnectFlow(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            log('STRIPE CONNECT : ${request.url}');

            // Onboarding finished. This used to match the bare string
            // 'returnurl', which worked only because the placeholder domain
            // happened to contain it.
            if (request.url.startsWith(AppConfig.stripeConnectReturnUrl)) {
              Navigator.of(context).pop(_connectResponse);
              return NavigationDecision.prevent;
            }

            // The account link expired or had already been used. Stripe's
            // guidance is to mint a new one and put the driver straight back
            // into it, which matters because these links last minutes.
            if (request.url.startsWith(AppConfig.stripeConnectRefreshUrl)) {
              logger.log.fine('Stripe account link expired; requesting a new one');
              _fetchStripeConnectUrl();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    _tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    _tagAlongUser = _tagAlongUserViewModel.tagAlongUser;

    return _controller != null
        ? WebViewWidget(controller: _controller!)
        : Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white),
            child: const CircularProgressIndicator(),
          );
  }

  /// Creates the driver's Stripe account if they don't have one, then opens
  /// Stripe's hosted onboarding.
  ///
  /// Everything is inside one try/finally because the progress dialog is
  /// dismissed by completing [completer]. The account-creation await used to
  /// sit outside the error handling, so any failure there escaped the method,
  /// left the completer uncompleted, and span the dialog forever with no way
  /// out of the screen.
  Future<void> _fetchStripeConnectUrl() async {
    final completer = Completer<void>();

    ProgressDialog.showWithCompleter(
      context,
      completer: completer,
      message: 'Loading',
    );

    try {
      String? stripeAccountId = _tagAlongUser?.stripeAccountId;

      if (stripeAccountId == null || stripeAccountId.isEmpty) {
        final StripeAccountCreateResponse accountCreateResponse =
            await StripeAccountRepository.instance.createAccount(
          StripeAccountCreateRequest(
            email: _tagAlongUser!.emailAddress,
            firstName: _tagAlongUser!.firstName,
            lastName: _tagAlongUser!.lastName,
            phone: _tagAlongUser!.phoneNumber,
            type: 'express',
          ),
        );

        /// save the account_id in the user profile
        _tagAlongUserViewModel.updateDriverAccountId(accountCreateResponse.data.id);
        await _tagAlongUserViewModel.updateTagAlongUserFirestore();
        stripeAccountId = accountCreateResponse.data.id;
      }

      final connectResponse = await StripeConnectRepository.instance.getStripeConnectLink(
        StripeConnectRequest(
          email: _tagAlongUser!.emailAddress,
          accountId: stripeAccountId,
          refreshUrl: AppConfig.stripeConnectRefreshUrl,
          returnUrl: AppConfig.stripeConnectReturnUrl,
          type: 'account_onboarding',
        ),
      );

      if (!mounted) return;
      setState(() {
        _connectResponse = connectResponse;
        _loadConnectFlow(connectResponse.data.url);
      });
    } catch (error, stackTrace) {
      logger.log.warning('Stripe Connect setup failed: $error', error, stackTrace);
      if (mounted) _showSetupFailed(error);
    } finally {
      // Dismisses the progress dialog. Must happen on every path.
      if (!completer.isCompleted) completer.complete();
    }
  }

  /// Payment setup is not something the driver can retry their way out of if
  /// the backend is unhappy, so this always offers a way off the screen.
  void _showSetupFailed(Object error) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('We could not set up payments'),
          content: Text(
            'Something went wrong connecting your account to Stripe. You can '
            'try again, or come back to this later from your account settings.'
            '\n\n$error',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchStripeConnectUrl();
              },
              child: const Text('Try again'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(RideBoardScreen.routeName, (route) => false);
              },
              child: const Text('Not now'),
            ),
          ],
        );
      },
    );
  }
}
