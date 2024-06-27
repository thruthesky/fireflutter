import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.people),
      title: Text('Friends: ${friend.uid}'),
    );
  }
}
