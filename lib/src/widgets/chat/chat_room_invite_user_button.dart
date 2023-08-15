import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_search_user_invite.dart';
import 'package:flutter/material.dart';

class InviteUserButton extends StatefulWidget {
  const InviteUserButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<InviteUserButton> createState() => _InviteUserButtonState();
}

class _InviteUserButtonState extends State<InviteUserButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Invite User'),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Invite User'),
              ),
              body: SearchUserInvite(
                room: widget.room,
              ),
            );
          },
        );
      },
    );
  }
}
