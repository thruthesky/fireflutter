import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_settings_screen.dart';
import 'package:flutter/material.dart';

class ChatSettingsButton extends StatefulWidget {
  const ChatSettingsButton({
    super.key,
    required this.room,
    this.onUpdateRoomSetting,
  });

  final ChatRoomModel room;
  final Function(ChatRoomModel room)? onUpdateRoomSetting;

  @override
  State<ChatSettingsButton> createState() => _ChatSettingsButtonState();
}

class _ChatSettingsButtonState extends State<ChatSettingsButton> {
  ChatRoomModel? _roomState;

  @override
  Widget build(BuildContext context) {
    _roomState ??= widget.room;

    return TextButton(
      child: const Text('Settings'),
      onPressed: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return ChatRoomSettingsScreen(
              room: _roomState!,
              onUpdateRoomSetting: (updatedRoom) {
                if (mounted) {
                  setState(() {
                    _roomState = updatedRoom;
                  });
                }
                widget.onUpdateRoomSetting?.call(updatedRoom);
              },
            );
          },
        );
      },
    );
  }
}
