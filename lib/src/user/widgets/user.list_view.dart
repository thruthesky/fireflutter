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
  final Function(User)? onTap;
  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: query ?? User.usersRef,
      shrinkWrap: shrinkWrap,
      itemBuilder: (_, snapshot) => UserTile(
        user: User.fromSnapshot(snapshot),
        onTap: onTap,
      ),
    );
  }
}
