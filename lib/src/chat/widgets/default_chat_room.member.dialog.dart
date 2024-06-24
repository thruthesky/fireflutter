import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomMemberDialog extends StatelessWidget {
  const DefaultChatRoomMemberDialog({
    super.key,
    required this.room,
    required this.member,
  });

  final ChatRoom room;
  final User member;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(uid: member.uid),
            const SizedBox(height: 16),
            Text(member.displayName),
          ],
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// MEMBER ACTIONS
          /// View User Profile
          TextButton(
            onPressed: () async {
              await UserService.instance.showPublicProfileScreen(
                context: context,
                user: member,
              );
              Navigator.pop(context);
            },
            child: const Text('View User Profile'),
          ),

          /// Remove User
          if (room.isMaster && member.uid != room.master && member.uid != myUid)
            TextButton(
              onPressed: () async {
                final re = await confirm(
                    context: context,
                    title: 'Remove User',
                    message: "Are you sure you want to remove this user?");
                if (re != true) return;
                room.remove(member.uid);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Remove User'),
            ),
        ],
      ),
    );
  }
}
