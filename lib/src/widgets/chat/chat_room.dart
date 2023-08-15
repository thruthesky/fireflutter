import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/widgets/chat/chat_message_box.dart';
import 'package:fireflutter/src/widgets/chat/chat_messages_list_view.dart';
import 'package:flutter/material.dart';

import 'chat_room_app_bar.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatRoomAppBar(room: room),
      body: Column(
        children: [
          Expanded(
            child: ChatMessagesListView(
              room: room,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatRoomMessageBox(room: room),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
