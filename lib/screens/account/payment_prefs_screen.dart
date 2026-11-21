import 'package:flutter/material.dart';
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/screens/account/add_payment_method_screen.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/card_brand.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/widgets/common/tagalong_components.dart';

/// "Payments" under Account: the user's saved cards, which one is their
/// default, and adding or removing a card.
class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Future<StripePaymentMethodResponse> _cards;

  /// The card just added, shown with a ring and a NEW tag until the next load.
  String? _newCardId;

  /// A card being made default or removed, so its row can show progress.
  String? _busyCardId;

  @override
  void initState() {
    super.initState();
    _cards = StripeCustomerRepository.instance.getMyPaymentMethods();
  }

  Future<void> _reload({String? newCardId}) async {
    final next = StripeCustomerRepository.instance.getMyPaymentMethods();
    setState(() {
      _cards = next;
      _newCardId = newCardId;
    });
    try {
      await next;
    } catch (_) {
      // The FutureBuilder shows the error; this only waits for the load.
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addCard(String? currentDefaultLabel) async {
    final result = await Navigator.of(context).pushNamed(
      AddPaymentMethodScreen.routeName,
      arguments: AddPaymentMethodArgs(currentDefaultLabel: currentDefaultLabel),
    );
    if (!mounted || result is! SavedCardResult) return;
    _toast(
        result.defaultFailed ? '${result.label} saved, but we couldn’t make it your default' : '${result.label} saved');
    await _reload(newCardId: result.paymentMethodId);
  }

  Future<void> _makeDefault(PaymentMethod card) async {
    setState(() => _busyCardId = card.id);
    try {
      await StripeCustomerRepository.instance.setDefaultPaymentMethod(card.id);
      if (!mounted) return;
      _toast('${CardBrand.label(card.card.brand, card.card.last4)} is now your default');
      await _reload();
    } catch (error, stack) {
      logger.log.warning('Could not make ${card.id} the default: $error', error, stack);
      if (mounted) _toast('We couldn’t change your default card. Please try again.');
    } finally {
      if (mounted) setState(() => _busyCardId = null);
    }
  }

  Future<void> _remove(PaymentMethod card) async {
    final label = CardBrand.label(card.card.brand, card.card.last4);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove card?'),
        content: Text('$label will be removed from your account. Rides you’ve already booked aren’t affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: TagAlongColors.errorInk),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busyCardId = card.id);
    try {
      await StripeCustomerRepository.instance.removePaymentMethod(card.id);
      if (!mounted) return;
      _toast('$label removed');
      await _reload();
    } catch (error, stack) {
      logger.log.warning('Could not remove ${card.id}: $error', error, stack);
      if (mounted) _toast('We couldn’t remove that card. Please try again.');
    } finally {
      if (mounted) setState(() => _busyCardId = null);
    }
  }

  void _showOptions(PaymentMethod card, bool isDefault) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _CardOptionsSheet(
        card: card,
        isDefault: isDefault,
        onMakeDefault: () {
          Navigator.pop(sheetContext);
          _makeDefault(card);
        },
        onRemove: () {
          Navigator.pop(sheetContext);
          _remove(card);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TagAlongTopBar(title: 'Payments'),
      body: FutureBuilder<StripePaymentMethodResponse>(
        future: _cards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            logger.log.warning('Could not load saved cards: ${snapshot.error}');
            return _Message(
              title: 'Couldn’t load your cards',
              body: 'Check your connection and try again.',
              action: 'Try again',
              onAction: _reload,
            );
          }

          final cards = snapshot.data!.data.data;
          final defaultId = snapshot.data!.data.defaultPaymentMethod;
          if (cards.isEmpty) {
            return _EmptyState(onAdd: () => _addCard(null));
          }

          PaymentMethod? defaultCard;
          for (final c in cards) {
            if (c.id == defaultId) defaultCard = c;
          }
          final defaultLabel =
              defaultCard == null ? null : CardBrand.label(defaultCard.card.brand, defaultCard.card.last4);

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  TagAlongSpace.gutter, TagAlongSpace.s4, TagAlongSpace.gutter, TagAlongSpace.s10),
              children: [
                TagAlongSectionHeader(title: 'Saved cards', count: '${cards.length}'),
                const SizedBox(height: TagAlongSpace.s3),
                for (final card in cards) ...[
                  _SavedCardRow(
                    card: card,
                    isDefault: card.id == defaultId,
                    isNew: card.id == _newCardId,
                    busy: card.id == _busyCardId,
                    onOptions: () => _showOptions(card, card.id == defaultId),
                  ),
                  const SizedBox(height: TagAlongSpace.s3),
                ],
                _AddCardTile(onTap: () => _addCard(defaultLabel)),
                const SizedBox(height: TagAlongSpace.s4),
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
                          'Cards are stored by Stripe. Your default card is selected first when you book a ride; '
                          'you can still pick another at checkout.',
                          style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SavedCardRow extends StatelessWidget {
  const _SavedCardRow({
    required this.card,
    required this.isDefault,
    required this.isNew,
    required this.busy,
    required this.onOptions,
  });

  final PaymentMethod card;
  final bool isDefault;
  final bool isNew;
  final bool busy;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final label = CardBrand.label(card.card.brand, card.card.last4);
    return TagAlongCard(
      border: isNew ? Border.all(color: TagAlongColors.brand, width: 2) : null,
      child: Row(
        children: [
          CardBrandBadge(brand: card.card.brand),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TagAlongText.titleSmall),
                const SizedBox(height: TagAlongSpace.s1),
                Wrap(
                  spacing: TagAlongSpace.s2,
                  runSpacing: TagAlongSpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Expires ${CardBrand.expiry(card.card.expMonth, card.card.expYear)}',
                        style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                    if (isDefault) const TagAlongTag(label: 'Default', tone: TagTone.lavender),
                    if (isNew && !isDefault) const TagAlongTag(label: 'New', tone: TagTone.mint),
                  ],
                ),
              ],
            ),
          ),
          busy
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  tooltip: 'Options for $label',
                  onPressed: onOptions,
                  icon: const Icon(Icons.more_horiz_rounded, color: TagAlongColors.textTertiary),
                ),
        ],
      ),
    );
  }
}

/// Dashed "Add payment method" tile.
class _AddCardTile extends StatelessWidget {
  const _AddCardTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: const _DashedBorderPainter(),
      child: Material(
        color: Colors.transparent,
        borderRadius: TagAlongRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(TagAlongSpace.s4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: TagAlongColors.subtle, shape: BoxShape.circle),
                  child: const Icon(Icons.add_rounded, size: 18, color: TagAlongColors.textBrand),
                ),
                const SizedBox(width: TagAlongSpace.s3),
                Text('Add payment method', style: TagAlongText.labelLarge.copyWith(color: TagAlongColors.textBrand)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardOptionsSheet extends StatelessWidget {
  const _CardOptionsSheet({
    required this.card,
    required this.isDefault,
    required this.onMakeDefault,
    required this.onRemove,
  });

  final PaymentMethod card;
  final bool isDefault;
  final VoidCallback onMakeDefault;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(TagAlongSpace.gutter, 0, TagAlongSpace.gutter, TagAlongSpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CardBrandBadge(brand: card.card.brand),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(CardBrand.label(card.card.brand, card.card.last4), style: TagAlongText.titleLarge),
                      Text('Expires ${CardBrand.expiry(card.card.expMonth, card.card.expYear)}',
                          style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TagAlongSpace.s4),
            TagAlongCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (!isDefault) ...[
                    _SheetAction(
                      icon: Icons.star_outline_rounded,
                      tileColor: TagAlongColors.subtle,
                      title: 'Make default card',
                      subtitle: 'Picked first when you book a ride',
                      onTap: onMakeDefault,
                    ),
                    const Padding(padding: EdgeInsets.only(left: 68), child: Divider(height: 1)),
                  ],
                  _SheetAction(
                    icon: Icons.delete_outline_rounded,
                    tileColor: TagAlongPalette.rose100,
                    color: TagAlongColors.errorInk,
                    title: 'Remove card',
                    subtitle: 'Rides you’ve already booked aren’t affected',
                    onTap: onRemove,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.tileColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = TagAlongColors.textPrimary,
  });

  final IconData icon;
  final Color tileColor;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: TagAlongSpace.s3),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: tileColor, borderRadius: TagAlongRadius.mdAll),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: TagAlongSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TagAlongText.titleSmall.copyWith(color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    Widget card(Color color, {double angle = 0, bool shadow = false}) => Transform.rotate(
          angle: angle,
          child: Container(
            width: 132,
            height: 84,
            decoration: BoxDecoration(
              color: color,
              borderRadius: TagAlongRadius.mdAll,
              boxShadow: shadow ? TagAlongShadows.level2 : null,
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(TagAlongSpace.s8, 72, TagAlongSpace.s8, TagAlongSpace.s8),
      children: [
        Center(
          child: ExcludeSemantics(
            child: SizedBox(
              width: 200,
              height: 150,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 10,
                    child: Container(
                      width: 168,
                      height: 168,
                      decoration: const BoxDecoration(color: TagAlongColors.subtle, shape: BoxShape.circle),
                    ),
                  ),
                  Positioned(left: 22, top: 34, child: card(TagAlongColors.toCampus, angle: -0.14)),
                  Positioned(left: 46, top: 46, child: card(TagAlongColors.brandSoft, shadow: true)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: TagAlongSpace.s5),
        Text('No saved cards yet', style: TagAlongText.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: TagAlongSpace.s2),
        Text(
          'Save a card now and booking a seat takes one tap. You can also add one at checkout.',
          style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TagAlongSpace.s6),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add payment method'),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body, required this.action, required this.onAction});

  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(TagAlongSpace.s8, 96, TagAlongSpace.s8, TagAlongSpace.s8),
      children: [
        Text(title, style: TagAlongText.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: TagAlongSpace.s2),
        Text(body,
            style: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: TagAlongSpace.s5),
        Center(child: OutlinedButton(onPressed: onAction, child: Text(action))),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TagAlongColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.75), const Radius.circular(TagAlongRadius.lg));
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
