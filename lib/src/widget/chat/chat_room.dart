import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  void initState() {
    super.initState();
    ChatService.instance.resetNoOfNewMessage(room: widget.room);
    ChatService.instance.clearLastMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          ChatService.instance.customize.chatRoomAppBarBuilder?.call(widget.room) ?? ChatRoomAppBar(room: widget.room),
      body: Column(
        children: [
          Expanded(
            child: ChatRoomMessageListView(
              room: widget.room,
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: ChatRoomMessageBox(room: widget.room),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
