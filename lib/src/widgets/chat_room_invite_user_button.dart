import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class InviteUserButton extends StatelessWidget {
  const InviteUserButton({
    super.key,
    required this.room,
    this.onInvite,
  });

  final ChatRoomModel room;
  final Function(String invitedUserUid)? onInvite;

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
                title: const Text('Invite Users'),
              ),
              body: InviteUserListView(
                // ! Is it better to relisten here? Will relistening, be a problem with number of reads?
                room: room,
                onInvite: (uid) {
                  onInvite?.call(uid);
                },
              ),
            );
          },
        );
      },
    );
  }
}
