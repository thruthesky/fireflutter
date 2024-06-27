import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await Friend.request(context: context, uid: uid);
      },
      child: const Text('Friend Request'),
    );
  }
}
