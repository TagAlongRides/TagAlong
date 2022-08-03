import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DriverStripeConnectRegistrationScreen extends StatefulWidget {
  const DriverStripeConnectRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<DriverStripeConnectRegistrationScreen> createState() =>
      _DriverStripeConnectRegistrationScreenState();
}

class _DriverStripeConnectRegistrationScreenState
    extends State<DriverStripeConnectRegistrationScreen> {
  StripeConnectResponse? _connectResponse;

  TagAlongUser? _tagAlongUser;
  late TagAlongUserViewModel _tagAlongUserViewModel;

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchStripeConnectUrl();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _themeData = Theme.of(context);
    _tagAlongUserViewModel =
        Provider.of<TagAlongUserViewModel>(context, listen: false);
    _tagAlongUser = _tagAlongUserViewModel.tagAlongUser;

    return _connectResponse != null
        ? WebView(
            initialUrl: _connectResponse!.data.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) async {
              _controller.complete(webViewController);
            },
            navigationDelegate: (NavigationRequest request) {
              log('STRIPE CONNECT : ${request.url}');
              //Stripe Connect Flow is completed
              //Update the account id and registration status
              if (request.url.contains('returnurl')) {
                Navigator.of(context).pop(_connectResponse);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          )
        : Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white),
            child: const CircularProgressIndicator(),
          );
  }

  void _fetchStripeConnectUrl() async {
    final completer = Completer<void>();

    ProgressDialog.showWithCompleter(
      context,
      completer: completer,
      message: 'Loading',
    );

    String? stripeAccountId;
    if (_tagAlongUser?.stripeAccountId == null) {
      final StripeAccountCreateResponse accountCreateResponse =
          await StripeAccountRepository.instance.createAccount(
        StripeAccountCreateRequest(
            email: _tagAlongUser!.emailAddress,
            firstName: _tagAlongUser!.firstName,
            lastName: _tagAlongUser!.lastName,
            phone: _tagAlongUser!.phoneNumber,
            type: 'custom'),
      );
      _tagAlongUserViewModel
          .updateDriverAccountId(accountCreateResponse.data.id);
      await _tagAlongUserViewModel.updateTagAlongUserFirestore();
      stripeAccountId = accountCreateResponse.data.id;
    } else {
      stripeAccountId = _tagAlongUser!.stripeAccountId;
    }

    StripeConnectRepository.instance
        .getStripeConnectLink(
      StripeConnectRequest(
        email: _tagAlongUser!.emailAddress,
        accountId: stripeAccountId!,
        refreshUrl: stripeConnectRefreshUrl,
        returnUrl: stripeConnectReturnUrl,
        type: stripeAccountId == null ? 'account_onboarding' : 'account_update',
      ),
    )
        .then((value) {
      setState(() {
        _connectResponse = value;
      });
    }).onError((error, stackTrace) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ok')),
            ],
          );
        },
      );
    }).then((value) => completer.complete());
  }
}
