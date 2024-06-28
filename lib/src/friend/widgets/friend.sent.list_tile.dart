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
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      onTap: () {
        UserService.instance.showPublicProfileScreen(
          context: context,
          uid: friend.uid,
        );
      },
      leading: UserAvatar(
        uid: friend.uid,
        cacheId: friend.uid,
      ),
      title: UserDisplayName(
        uid: friend.uid,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: UserDoc(
        uid: friend.uid,
        builder: (user) {
          return Text(user.stateMessage);
        },
      ),
      trailing: Value(
        ref: friend.ref,
        builder: (snapshot) {
          final snapshotData = Map<String, dynamic>.from(snapshot);
          final friendData = Friend.fromJson(snapshotData, friend.ref);
          if (friendData.acceptedAt != null) {
            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Accepted"),
            );
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
