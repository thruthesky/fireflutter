import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({
    super.key,
    this.otherUid,
    this.roomId,
    this.room,
  });

  final String? otherUid;
  final String? roomId;
  final ChatRoom? room;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        ChatService.instance.showChatRoomScreen(
          context: context,
          otherUid: otherUid,
          roomId: roomId,
          room: room,
        );
      },
      child: Text(T.chat.tr),
    );
  }
}
