import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatService.instance.customize.chatRoomAppBarBuilder?.call(room) ?? ChatRoomAppBar(room: room),
      body: Column(
        children: [
          Expanded(
            child: ChatRoomMessageListView(
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
