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
              padding: EdgeInsets.only(right: 12.0),
              child: Text("Accepted"),
            );
          }
          if (friendData.rejectedAt != null) {
            return const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Text("Rejected"),
            );
          }
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Friend.accept(
                    context: context,
                    uid: friendData.uid,
                  );
                },
                icon: const Icon(
                  Icons.check,
                ),
              ),
              IconButton(
                onPressed: () {
                  Friend.reject(
                    context: context,
                    uid: friendData.uid,
                  );
                },
                icon: const Icon(
                  Icons.close,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
