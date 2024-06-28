import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class MutualFriendBuilder extends StatelessWidget {
  const MutualFriendBuilder({
    super.key,
    required this.friend,
    this.yes,
    this.no,
  });

  final Friend friend;
  final Widget? yes;
  final Widget? no;

  @override
  Widget build(BuildContext context) {
    return Value(
      ref: Friend.myListRef.child(friend.uid),
      builder: (myFriendData) {
        if (myFriendData == null) {
          return no ?? const SizedBox.shrink();
        } else {
          return yes ?? const SizedBox.shrink();
        }
      },
    );
  }
}
