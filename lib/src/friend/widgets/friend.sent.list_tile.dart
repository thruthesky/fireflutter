import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendRequestSentListTile extends StatelessWidget {
  const FriendRequestSentListTile({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.people),
      title: Text('Friends: ${friend.uid}'),
      trailing: Value(
        ref: friend.ref,
        builder: (snapshot) {
          final snapshotData = Map<String, dynamic>.from(snapshot);
          final friendData = Friend.fromJson(snapshotData, friend.ref);
          if (friendData.acceptedAt != null) {
            return const Text("Accepted");
          }
          return IconButton(
            onPressed: () async {
              final re = await confirm(
                context: context,
                title: "Cancel Request",
                message: "Are you sure you want to cancel the friend request?",
              );
              if (re == true) {
                Friend.cancelRequest(
                  context: context,
                  uid: friendData.uid,
                );
              }
            },
            icon: const Icon(
              Icons.close,
            ),
          );
        },
      ),
    );
  }
}
