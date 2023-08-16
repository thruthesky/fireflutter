import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_members_list_view.dart';
import 'package:flutter/material.dart';

class ChatMembersButton extends StatelessWidget {
  const ChatMembersButton({
    super.key,
    required this.room,
  });

  final Room room;

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
