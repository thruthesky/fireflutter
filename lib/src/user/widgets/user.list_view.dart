import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// UserListView
///
/// Displays a list of users.
///
/// Example:
/// ```dart
/// UserListView()
/// ```
class UserListView extends StatelessWidget {
  const UserListView({
    super.key,
    this.query,
    this.shrinkWrap = false,
    this.onTap,
  });

  final Query? query;
  final bool shrinkWrap;
  final Function(UserModel)? onTap;
  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: query ?? UserModel.usersRef,
      shrinkWrap: shrinkWrap,
      itemBuilder: (_, snapshot) => UserTile(
        user: UserModel.fromSnapshot(snapshot),
        onTap: onTap,
      ),
    );
  }
}
