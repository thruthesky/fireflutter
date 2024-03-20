import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
    this.uid,
    this.roomId,
    this.room,
  });

  final String? uid;
  final String? roomId;
  final ChatRoom? room;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        ChatService.instance.showChatRoomScreen(
          context: context,
          uid: uid,
          roomId: roomId,
          room: room,
        );
      },
      child: Text(T.chat.tr),
    );
  }
}
