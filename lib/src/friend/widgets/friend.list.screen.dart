import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendListScreen extends StatelessWidget {
  static const String routeName = '/FriendList';
  const FriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: const FriendListView(),
    );
  }
}
