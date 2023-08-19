import 'package:fireflutter/src/model/room.dart';
import 'package:fireflutter/src/widget/chat/chat_room_settings_screen.dart';
import 'package:flutter/material.dart';

class ChatSettingsButton extends StatelessWidget {
  const ChatSettingsButton({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('Settings'),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return ChatRoomSettingsScreen(
              room: room,
            );
          },
        );
      },
    );
  }
}
