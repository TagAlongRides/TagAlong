import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/screens/account/contact_us_screen.dart';
import 'package:tagalong/screens/account/notification_prefs_screen.dart';
import 'package:tagalong/screens/account/payment_prefs_screen.dart';
import 'package:tagalong/screens/account/privacy_policy_screen.dart';
import 'package:tagalong/screens/account/update_personal_info_screen.dart';
import 'package:tagalong/services/auth_service.dart';
import '../../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;
import 'package:tagalong/themes/tagalong_theme.dart' as theme;
import 'package:tagalong/widgets/account/account_setting_tile.dart';

class AccountSettingsScreen extends StatelessWidget {
  static const routeName = '/account-settings';
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.log.fine('Account Settings Build');
    var tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    var divider = const Divider(height: 0, thickness: 1);
    var sizedBox = const SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBox,
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(tagAlongUserViewModel.tagAlongUser!.profilePictureUrl),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tagAlongUserViewModel.tagAlongUser!.firstName} ${tagAlongUserViewModel.tagAlongUser!.lastName}',
                  style: theme.TagAlongTheme.lightTextTheme.headline6!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  tagAlongUserViewModel.tagAlongUser?.graduationYear == null
                      ? '${tagAlongUserViewModel.tagAlongUser!.institution}'
                      : '${tagAlongUserViewModel.tagAlongUser!.institution} Class of ${tagAlongUserViewModel.tagAlongUser!.graduationYear}',
                  style: theme.TagAlongTheme.lightTextTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
                )
              ],
            ),
          ],
        ),
        sizedBox,
        AccountSettingTile(
          icon: Icons.person_outline,
          title: 'Update Personal Information',
          subtitle: 'Change your personal account info',
          onTap: () {
            Navigator.of(context).pushNamed(UpdatePersonalInfoScreen.routeName);
          },
        ),
        divider,
        AccountSettingTile(
          icon: Icons.notifications_outlined,
          title: 'Notification Settings',
          subtitle: 'Choose which messages you want to receive',
          onTap: () {
            Navigator.of(context).pushNamed(NotificationPrefsScreen.routeName);
          },
        ),
        divider,
        AccountSettingTile(
          icon: Icons.payment_outlined,
          title: 'Payment Methods',
          subtitle: 'Change your personal account info',
          onTap: () {
            Navigator.of(context).pushNamed(PaymentMethodsScreen.routeName);
          },
        ),
        sizedBox,
        AccountSettingTile(
          icon: Icons.policy_outlined,
          title: 'Privacy Policy',
          onTap: () {
            Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
          },
        ),
        divider,
        AccountSettingTile(
          icon: Icons.phone_outlined,
          title: 'Contact Us',
          onTap: () {
            Navigator.of(context).pushNamed(ContactUsScreen.routeName);
          },
        ),
        sizedBox,
        AccountSettingTile(
          icon: Icons.logout_outlined,
          title: 'Log Out',
          isLogout: true,
          onTap: () {
            auth.signOut();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/');
          },
        ),
      ],
    );
  }
}
