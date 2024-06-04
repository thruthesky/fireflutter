import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomCreateButton extends StatelessWidget {
  const ChatRoomCreateButton({super.key, this.icon});

  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon ?? const Icon(Icons.add),
      onPressed: () => ChatService.instance
          .showChatRoomCreate(
            context: context,
          )
          .then(
            (room) => ChatService.instance.showChatRoomScreen(
              context: context,
              room: room,
            ),
          ),
    );
  }
}
