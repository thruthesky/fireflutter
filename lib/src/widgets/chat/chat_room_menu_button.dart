import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
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
        return ChatService.instance.openChatRoomMenu(room: widget.room, context: context);
      },
    );
  }
}
