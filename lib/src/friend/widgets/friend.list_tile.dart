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
    );
  }
}
