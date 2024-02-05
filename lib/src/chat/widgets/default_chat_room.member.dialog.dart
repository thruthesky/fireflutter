import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultChatRoomMemberDialog extends StatelessWidget {
  const DefaultChatRoomMemberDialog({
    super.key,
    required this.room,
    required this.member,
  });

  final ChatRoomModel room;
  final UserModel member;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          UserAvatar(uid: member.uid),
          const SizedBox(height: 16),
          Text(member.displayName),
        ],
      ),
      content: Wrap(
        children: [
          /// MEMBER ACTIONS
          /// Remove User
          TextButton(
            onPressed: () {
              room.remove(member.uid);
              Navigator.pop(context);
            },
            child: const Text('Remove User'),
          ),
        ],
      ),
    );
  }
}
