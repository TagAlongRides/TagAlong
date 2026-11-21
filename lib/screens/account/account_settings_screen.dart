import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/account/support_screen.dart';
import 'package:tagalong/screens/account/notification_prefs_screen.dart';
import 'package:tagalong/screens/account/payment_prefs_screen.dart';
import 'package:tagalong/screens/account/privacy_policy_screen.dart';
import 'package:tagalong/screens/account/update_personal_info_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import 'package:tagalong/services/notification_service.dart';
import 'package:tagalong/viewmodels/ride_board_view_model.dart';
import '../../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:stripe_repo/stripe_repo.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';
import 'package:tagalong/util/card_brand.dart';
import 'package:tagalong/widgets/common/tagalong_components.dart';

class AccountSettingsScreen extends StatelessWidget {
  static const routeName = '/account-settings';
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.log.fine('Account Settings Build');

    return Material(
      color: TagAlongColors.canvas,
      child: Consumer<TagAlongUserViewModel>(
        builder: (context, users, child) {
          final user = users.tagAlongUser!;
          final school =
              user.graduationYear == null ? user.institution : '${user.institution} · Class of ${user.graduationYear}';

          return ListView(
            padding: EdgeInsets.fromLTRB(
              TagAlongSpace.gutter,
              MediaQuery.paddingOf(context).top + TagAlongSpace.s2,
              TagAlongSpace.gutter,
              MediaQuery.paddingOf(context).bottom + TagAlongSpace.s6,
            ),
            children: [
              TagAlongPageHeader(
                title: 'Account',
                trailing: TagAlongIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit personal info',
                  onPressed: () => Navigator.of(context).pushNamed(UpdatePersonalInfoScreen.routeName),
                ),
              ),
              const SizedBox(height: TagAlongSpace.s4),

              // Profile
              TagAlongCard(
                radius: TagAlongRadius.xl,
                padding: const EdgeInsets.all(TagAlongSpace.s5),
                child: Row(
                  children: [
                    TagAlongAvatar(
                      name: '${user.firstName} ${user.lastName}',
                      imageUrl: user.profilePictureUrl,
                      size: 60,
                      color: TagAlongColors.brandSoft,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${user.firstName} ${user.lastName}', style: TagAlongText.titleMedium),
                          const SizedBox(height: 2),
                          Text(user.emailAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                          if (school.isNotEmpty)
                            Text(school, style: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary)),
                        ],
                      ),
                    ),
                    if (users.isActiveDriver()) const TagAlongTag(label: 'Driver', tone: TagTone.mint),
                  ],
                ),
              ),
              const SizedBox(height: TagAlongSpace.s6),

              TagAlongSettingsGroup(title: 'Account', rows: [
                TagAlongSettingsRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal info',
                  subtitle: 'Name, phone, school email',
                  onTap: () => Navigator.of(context).pushNamed(UpdatePersonalInfoScreen.routeName),
                ),
                TagAlongSettingsRow(
                  icon: Icons.notifications_none_rounded,
                  tileColor: TagAlongColors.warning,
                  title: 'Notifications',
                  subtitle: 'Choose which messages you receive',
                  onTap: () => Navigator.of(context).pushNamed(NotificationPrefsScreen.routeName),
                ),
                const _PaymentsRow(),
              ]),
              const SizedBox(height: TagAlongSpace.s6),

              TagAlongSettingsGroup(title: 'Help', rows: [
                TagAlongSettingsRow(
                  icon: Icons.help_outline_rounded,
                  tileColor: TagAlongColors.fromCampus,
                  title: 'FAQs & support',
                  onTap: () => Navigator.of(context).pushNamed(SupportScreen.routeName),
                ),
                TagAlongSettingsRow(
                  icon: Icons.shield_outlined,
                  title: 'Privacy policy',
                  onTap: () => Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName),
                ),
              ]),
              const SizedBox(height: TagAlongSpace.s6),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: TagAlongColors.errorInk,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: () => _logOut(context),
                child: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final userViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    final rideBoardViewModel = Provider.of<RideBoardViewModel>(context, listen: false);

    // Stop pushing ride notifications to a device this user has just
    // signed out of.
    final userId = userViewModel.tagAlongUser?.id;
    if (userId != null) {
      await NotificationService.instance.unregisterDevice(userId);
    }
    await auth.signOut();

    // Drop this user's state, or whoever signs in next on this device
    // inherits it.
    userViewModel.clear();
    rideBoardViewModel.reset();

    if (!context.mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed('/');
  }
}

/// The "Payments" row, summarising the user's cards: "Visa •••• 4242 · 2 saved
/// cards". Re-reads them on returning from the Payments screen.
class _PaymentsRow extends StatefulWidget {
  const _PaymentsRow();

  @override
  State<_PaymentsRow> createState() => _PaymentsRowState();
}

class _PaymentsRowState extends State<_PaymentsRow> {
  String _subtitle = 'Your saved cards';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response = await StripeCustomerRepository.instance.getMyPaymentMethods();
      final cards = response.data.data;
      String subtitle;
      if (cards.isEmpty) {
        subtitle = 'Add a card for faster booking';
      } else {
        final main = cards.firstWhere(
          (card) => card.id == response.data.defaultPaymentMethod,
          orElse: () => cards.first,
        );
        final count = cards.length == 1 ? '1 saved card' : '${cards.length} saved cards';
        subtitle = '${CardBrand.label(main.card.brand, main.card.last4)} · $count';
      }
      if (mounted) setState(() => _subtitle = subtitle);
    } catch (error) {
      // Keep the generic line; the Payments screen explains any failure.
      logger.log.fine('Could not summarise saved cards: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TagAlongSettingsRow(
      icon: Icons.credit_card_rounded,
      tileColor: TagAlongColors.toCampus,
      title: 'Payments',
      subtitle: _subtitle,
      onTap: () async {
        await Navigator.of(context).pushNamed(PaymentMethodsScreen.routeName);
        _load();
      },
    );
  }
}
