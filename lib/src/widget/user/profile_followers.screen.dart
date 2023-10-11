import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ProfileFollowerSceen extends StatelessWidget {
  const ProfileFollowerSceen({super.key, this.itemBuilder, this.user});

  final Widget Function(User)? itemBuilder;
  final User? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('ProfileFollowerBackButton'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Followers'),
      ),
      body: itemBuilder?.call(user!) ?? UserListView.builder(uids: user!.followers),
    );
  }
}
