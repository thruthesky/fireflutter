import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    this.room,
    this.futureRoom,
  }) : assert(room != null || futureRoom != null,
            "One of room or futureRoom must be not null");

  final Room? room;
  final Future<Room>? futureRoom;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoomScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      ChatService.instance.resetNoOfNewMessage(room: widget.room!);
      ChatService.instance.clearLastMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar;
    Widget body;

    if (widget.room != null) {
      appBar = ChatService.instance.customize.chatRoomAppBarBuilder
              ?.call(widget.room!) ??
          ChatRoomAppBar(room: widget.room!);
      body = Column(
        children: [
          Expanded(
            child: ChatRoomMessageListView(
              room: widget.room!,
            ),
          ),
          ChatRoomMessageBox(room: widget.room!),
        ],
      );
    } else {
      appBar = AppBar(
        title: const Text("Loading"),
      );
      body = const Column(
        children: [
          Text('Loading'),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}
