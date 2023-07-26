import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ChatRoomMenuButton extends StatefulWidget {
  const ChatRoomMenuButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

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
            widget.room.group == true ? null : await EasyChat.instance.getOtherUserFromSingleChatRoom(widget.room);
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
