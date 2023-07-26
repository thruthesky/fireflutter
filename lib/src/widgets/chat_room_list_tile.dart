import 'package:easychat/easychat.dart';
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
        if (joinOnEnter) EasyChat.instance.joinRoom(room: room);
        EasyChat.instance.showChatRoom(context: context, room: room);
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
