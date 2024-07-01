import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendListScreen extends StatelessWidget {
  static const String routeName = '/FriendList';
  const FriendListScreen({
    super.key,
    this.title,
    this.uid,
  });

  final String? title;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? T.friends.tr),
      ),
      body: FriendListView(uid: uid),
    );
  }
}
