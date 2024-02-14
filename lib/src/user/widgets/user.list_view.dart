import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// UserListView
///
/// Displays a list of users.
class UserListView extends StatelessWidget {
  const UserListView({super.key, this.query, this.shrinkWrap = false});

  final Query? query;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: query ?? Ref.users,
      shrinkWrap: shrinkWrap,
      itemBuilder: (_, snapshot) => UserTile(
        user: UserModel.fromSnapshot(snapshot),
        onTap: (user) {
          UserService.instance.showPublicProfile(
            context: context,
            uid: user.uid,
          );
        },
      ),
    );
  }
}
