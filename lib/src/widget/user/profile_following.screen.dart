import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileFollowingScreen extends StatelessWidget {
  const ProfileFollowingScreen({super.key, this.itemBuilder, this.user});

  final Widget Function(User)? itemBuilder;
  final User? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: itemBuilder?.call(user!) ??
          UserListView.builder(uids: user!.followings),
    );
  }
}
