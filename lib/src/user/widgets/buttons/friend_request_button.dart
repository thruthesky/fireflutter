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
    return Value(
        ref: Friend.mySentRequestListRef,
        builder: (value) {
          if (value == null) {
            return ElevatedButton(
              onPressed: () async {
                await Friend.request(context: context, uid: uid);
              },
              child: const Text('Friend Request'),
            );
          } else {
            return ElevatedButton(
              onPressed: () async {
                final re = await confirm(
                  context: context,
                  title: "Already Requested",
                  message:
                      "You have already requested this user. Do you want to cancel the request?",
                );
                if (re == true) {
                  await Friend.cancelRequest(context: context, uid: uid);
                }
              },
              child: const Text('Requested'),
            );
          }
        });
  }
}
