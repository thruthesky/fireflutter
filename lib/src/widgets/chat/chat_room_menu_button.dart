import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_menu_screen.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuButton extends StatefulWidget {
  const ChatRoomMenuButton({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<ChatRoomMenuButton> createState() => _ChatRoomMenuButtonState();
}

class _ChatRoomMenuButtonState extends State<ChatRoomMenuButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () async {
        final otherUser =
            widget.room.group == true ? null : await ChatService.instance.getOtherUserFromSingleChatRoom(widget.room);
        if (context.mounted) {
          showGeneralDialog(
            context: context,
            pageBuilder: (context, _, __) {
              return ChatRoomMenuScreen(
                room: widget.room,
                otherUser: otherUser,
              );
            },
          );
        }
      },
    );
  }
}
