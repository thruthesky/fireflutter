import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendRequestReceivedListTile extends StatelessWidget {
  const FriendRequestReceivedListTile({
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
            final friendData = Friend.fromJson(snapshot, friend.ref);

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    // TODO accept
                  },
                  icon: const Icon(
                    Icons.check,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO reject
                  },
                  icon: const Icon(
                    Icons.close,
                  ),
                )
              ],
            );
          }),
    );
  }
}
