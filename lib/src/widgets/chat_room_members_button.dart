import 'package:easychat/easychat.dart';
import 'package:flutter/material.dart';

class ChatMembersButton extends StatelessWidget {
  const ChatMembersButton({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Members'),
      ),
      body: ChatRoomMembersListView(room: room),
    );
  }
}
