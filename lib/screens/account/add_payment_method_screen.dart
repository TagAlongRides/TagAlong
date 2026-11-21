import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide CardBrand;
import 'package:provider/provider.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/card_brand.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// What [AddPaymentMethodScreen] needs to know about the user's cards.
class AddPaymentMethodArgs {
  const AddPaymentMethodArgs({this.currentDefaultLabel});

  /// "Visa •••• 4242" when the user already has a default card, else null.
  final String? currentDefaultLabel;
}

/// What [AddPaymentMethodScreen] pops with once a card is saved.
class SavedCardResult {
  const SavedCardResult({required this.paymentMethodId, required this.label, this.defaultFailed = false});

  final String paymentMethodId;

  /// "Visa •••• 5556".
  final String label;

  /// The card saved but making it the default did not.
  final bool defaultFailed;
}

/// Saves a card to the user's Stripe customer without charging it.
///
/// The card is collected by Stripe's native card form, so the app never sees
/// the full number. Saving creates a SetupIntent on the server and confirms it
/// here, which also runs any check the bank asks for (3-D Secure).
class AddPaymentMethodScreen extends StatefulWidget {
  static const routeName = '/add-payment-method';
  const AddPaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _SaveError {
  const _SaveError(this.title, this.body);
  final String title;
  final String body;
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _controller = CardFormEditController();
  bool? _makeDefault;
  bool _saving = false;
  _SaveError? _error;

  AddPaymentMethodArgs get _args =>
      (ModalRoute.of(context)?.settings.arguments as AddPaymentMethodArgs?) ?? const AddPaymentMethodArgs();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCardChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onCardChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onCardChanged() => setState(() {
        // Editing the card clears the last error; the form's red border would
        // otherwise outlive the problem.
        if (_error != null && !_saving) _error = null;
      });

  CardFieldInputDetails get _details => _controller.details;

  Future<void> _save() async {
    final details = _details;
    if (!details.complete || _saving) return;
    final makeDefault = _makeDefault ?? _args.currentDefaultLabel == null;
    setState(() {
      _saving = true;
      _error = null;
    });

    final email = Provider.of<TagAlongUserViewModel>(context, listen: false).tagAlongUser?.emailAddress;
    try {
      final clientSecret = await StripeCustomerRepository.instance.createSetupIntent();
      final intent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
                email: email,
                address: Address(
                  postalCode: details.postalCode,
                  country: 'US',
                  city: null,
                  line1: null,
                  line2: null,
                  state: null,
                )),
          ),
        ),
      );

      var defaultFailed = false;
      if (makeDefault) {
        try {
          await StripeCustomerRepository.instance.setDefaultPaymentMethod(intent.paymentMethodId);
        } catch (error, stack) {
          logger.log.warning('Card ${intent.paymentMethodId} saved but not made default: $error', error, stack);
          defaultFailed = true;
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(SavedCardResult(
        paymentMethodId: intent.paymentMethodId,
        label: CardBrand.label(details.brand, details.last4 ?? ''),
        defaultFailed: defaultFailed,
      ));
    } on StripeException catch (error) {
      if (!mounted) return;
      final info = error.error;
      setState(() {
        _saving = false;
        // Closing the bank's check is the user's choice, not a failure.
        if (info.code == FailureCode.Canceled) return;
        final declined = info.declineCode != null || info.stripeErrorCode == 'card_declined';
        _error = declined
            ? const _SaveError(
                'This card was declined',
                'Your bank didn’t approve it. Try a different card, or contact your bank and try again.',
              )
            : _SaveError(
                'We couldn’t save this card',
                info.localizedMessage ?? info.message ?? 'Check the details and try again.',
              );
      });
    } catch (error, stack) {
      logger.log.severe('Saving a card failed: $error', error, stack);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = const _SaveError(
          'We couldn’t save this card',
          'Something went wrong on our side. Please try again in a moment.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    final currentDefault = _args.currentDefaultLabel;
    final makeDefault = _makeDefault ?? currentDefault == null;

    return Scaffold(
      appBar: const TagAlongTopBar(title: 'Add payment method'),
      bottomNavigationBar: TagAlongStickyBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: details.complete && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: TagAlongColors.textTertiary),
                  )
                : const Text('Save card'),
          ),
        ),
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(TagAlongSpace.gutter, TagAlongSpace.s2, TagAlongSpace.gutter, TagAlongSpace.s6),
        children: [
          _CardPreview(details: details),
          const SizedBox(height: TagAlongSpace.s5),
          if (_error != null) ...[
            _ErrorNotice(error: _error!),
            const SizedBox(height: TagAlongSpace.s5),
          ],
          const TagAlongOverline('Card details'),
          const SizedBox(height: TagAlongSpace.s2),
          AbsorbPointer(
            absorbing: _saving,
            child: CardFormField(
              controller: _controller,
              countryCode: 'US',
              style: CardFormStyle(
                backgroundColor: TagAlongColors.surface,
                borderColor: _error != null ? TagAlongColors.errorInk : TagAlongColors.border,
                borderWidth: 2,
                borderRadius: TagAlongRadius.md.round(),
                cursorColor: TagAlongColors.brand,
                textColor: TagAlongColors.textPrimary,
                textErrorColor: TagAlongColors.errorInk,
                placeholderColor: TagAlongColors.textTertiary,
                fontSize: 16,
              ),
            ),
          ),
          if (details.complete && _error == null)
            Padding(
              padding: const EdgeInsets.only(left: TagAlongSpace.s1, top: TagAlongSpace.s1),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 16, color: TagAlongColors.successInk),
                  const SizedBox(width: 6),
                  Text('Card details look good',
                      style: TagAlongText.bodySmall
                          .copyWith(color: TagAlongColors.successInk, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: TagAlongSpace.s5),
          TagAlongCard(
            padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: makeDefault,
              onChanged: _saving ? null : (value) => setState(() => _makeDefault = value),
              title: Text('Use as my default card', style: TagAlongText.titleSmall),
              subtitle: Text(
                currentDefault == null
                    ? 'We’ll pick it first when you book a ride'
                    : 'Replaces $currentDefault as your default',
                style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: TagAlongSpace.s5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(Icons.lock_outline_rounded, size: 16, color: TagAlongColors.textTertiary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your card is saved securely with Stripe. TagAlong never sees or stores your full card number.',
                    style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastel card that fills in brand, last four and expiry as the form reports
/// them. The full number never reaches the app.
class _CardPreview extends StatelessWidget {
  const _CardPreview({required this.details});

  final CardFieldInputDetails details;

  @override
  Widget build(BuildContext context) {
    final last4 = details.last4;
    final hasExpiry = details.expiryMonth != null && details.expiryYear != null;
    final filled = last4 != null && last4.isNotEmpty;
    final ink = filled ? TagAlongColors.textPrimary : TagAlongColors.textSecondary;

    return Semantics(
      label: filled ? 'Card preview, ${CardBrand.label(details.brand, last4)}' : 'Card preview',
      excludeSemantics: true,
      child: Container(
        height: 196,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: TagAlongColors.brandSoft, borderRadius: TagAlongRadius.lgAll),
        child: Stack(
          children: [
            Positioned(right: -40, top: -48, child: _blob(168, TagAlongColors.toCampus)),
            Positioned(right: 64, bottom: -36, child: _blob(88, TagAlongColors.success)),
            Padding(
              padding: const EdgeInsets.all(TagAlongSpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('CREDIT OR DEBIT CARD',
                            style: TagAlongText.overline.copyWith(color: TagAlongColors.textSecondary)),
                      ),
                      details.brand == null || details.brand!.isEmpty
                          ? Container(
                              width: 48,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                borderRadius: TagAlongRadius.smAll,
                              ),
                              child:
                                  const Icon(Icons.credit_card_rounded, size: 20, color: TagAlongColors.textSecondary),
                            )
                          : CardBrandBadge(brand: details.brand, color: TagAlongColors.surface),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•••• •••• •••• ${filled ? last4 : '••••'}',
                        style: TagAlongText.titleLarge.copyWith(color: ink, letterSpacing: 2),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasExpiry
                            ? 'Expires ${CardBrand.expiry(details.expiryMonth!, details.expiryYear!)}'
                            : 'Expires MM/YY',
                        style: TagAlongText.bodySmall.copyWith(color: ink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _ErrorNotice extends StatelessWidget {
  const _ErrorNotice({required this.error});

  final _SaveError error;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: 14),
        decoration: BoxDecoration(color: TagAlongPalette.rose100, borderRadius: TagAlongRadius.lgAll),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.error_outline_rounded, size: 20, color: TagAlongColors.errorInk),
            ),
            const SizedBox(width: TagAlongSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(error.title, style: TagAlongText.titleSmall.copyWith(color: TagAlongColors.errorInk)),
                  const SizedBox(height: 2),
                  Text(error.body, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
