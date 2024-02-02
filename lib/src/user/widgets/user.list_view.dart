import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseListView(
      query: Ref.users,
      itemBuilder: (_, snapshot) => UserTile(
        user: UserModel.fromSnapshot(snapshot),
        onTap: (user) {
          UserService.instance
              .showPublicProfile(context: context, uid: user.uid);
        },
      ),
    );
  }
}
