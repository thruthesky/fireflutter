import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageMenuBottomSheet extends StatelessWidget {
  const ChatRoomMessageMenuBottomSheet({
    super.key,
    required this.chat,
    required this.message,
  });

  final ChatModel chat;
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('@여기서 부터....'),
        ListTile(
          title: const Text('메세지 삭제'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('사용자 차단'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }
}
