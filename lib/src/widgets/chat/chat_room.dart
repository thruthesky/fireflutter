import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
    required this.room,
  });

  final ChatRoomModel room;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  ChatRoomModel? roomState;

  @override
  Widget build(BuildContext context) {
    // Manage this state
    roomState ??= widget.room;

    return Scaffold(
      appBar: ChatRoomAppBar(room: roomState!),
      body: Column(
        children: [
          Expanded(
            child: ChatMessagesListView(
              room: roomState!,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChatRoomMessageBox(room: roomState!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
