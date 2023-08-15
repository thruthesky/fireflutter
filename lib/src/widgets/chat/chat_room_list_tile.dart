import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_list_tile_name.dart';
import 'package:fireflutter/src/widgets/chat/chat_room_no_of_new_messages_text.dart';
import 'package:flutter/material.dart';

class ChatRoomListTile extends StatelessWidget {
  const ChatRoomListTile({
    super.key,
    required this.room,
    this.joinOnEnter = false,
  });
  final ChatRoomModel room;
  final bool joinOnEnter;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ChatRoomListTileName(room: room),
      onTap: () {
        if (joinOnEnter) room.join();
        ChatService.instance.showChatRoom(context: context, room: room);
      },
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatRoomNoOfNewMessagesText(room: room),
        ],
      ),
    );
  }
}
