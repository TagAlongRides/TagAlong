import 'package:flutter/material.dart';
import 'package:tagalong/themes/tagalong_theme.dart';

class AccountSettingTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Function onTap;
  final bool isLogout;

  const AccountSettingTile({
    Key? key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: icon != null
            ? Icon(
                icon,
                size: 36,
              )
            : null,
        title: Text(
          title,
          style: isLogout ? const TextStyle(color: Colors.red) : null,
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: isLogout ? null : const Icon(Icons.chevron_right_outlined),
        onTap: () => onTap(),
      ),
    );
  }
}
