import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendListScreen extends StatefulWidget {
  static const String routeName = '/FriendList';
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend'),
      ),
      body: const FriendListView(),
    );
  }
}
