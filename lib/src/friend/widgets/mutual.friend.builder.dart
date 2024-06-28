import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

// TODO ask for help how is it going to be used
class MutualFriendBuilder extends StatelessWidget {
  const MutualFriendBuilder({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Value(
      ref: Friend.myListRef.child(friend.uid),
      builder: (myFriendData) {
        if (myFriendData == null) {
          return const Text("Not Mutual");
        } else {
          return const Text("Mutual");
        }
      },
    );
  }
}
