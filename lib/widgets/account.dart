import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagalong/services/auth_service.dart';
import '../viewmodels/tagalong_user_view_model.dart';
import 'package:tagalong/util/log.dart' as logger;

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    var tagAlongUserViewModel = Provider.of<TagAlongUserViewModel>(context, listen: false);
    logger.log.fine('Account Build');
    // TODO: Solely for debugging the profile picture
    return Center(
      child: CircleAvatar(
        maxRadius: 100,
        backgroundImage: NetworkImage(
          tagAlongUserViewModel.tagAlongUser!.profilePictureUrl
        ),
      )
    );
  }
}
