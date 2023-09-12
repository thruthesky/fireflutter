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
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('AdminUserList',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface)),
      ),
      body: const UserListView(),
    );
  }
}
