import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminUserListScreen extends StatefulWidget {
  static const String routeName = '/AdminUserList';
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(T.fullUserList.tr),
      ),
      body: FirebaseDatabaseListView(
        query: User.usersRef,
        itemBuilder: (context, doc) {
          final user = User.fromSnapshot(doc);
          return ListTile(
            leading: UserAvatar(
              uid: user.uid,
            ),
            title: Text(
              user.displayName.isNotEmpty ? user.displayName : 'No name',
            ),
            subtitle: Text(user.uid),
            // trailing: Text(isAdmin ? T.master.tr : ''),
            onTap: () {
              AdminService.instance.showUserUpdate(
                context: context,
                uid: user.uid,
              );
            },
          );
        },
      ),
    );
  }
}
