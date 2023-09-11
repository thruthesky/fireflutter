import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    this.room,
    this.user,
  }) : assert(room != null || user != null,
            "One of room or user must be not null");

  final Room? room;
  final User? user;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoomScreen> {
  Room? room;
  Future<Room>? futureRoom;
  Future<void>? futureRoomJoin;

  @override
  void initState() {
    super.initState();
    // If it is 1:1 chat, get the chat room. (or create if it does not exist)
    if (widget.user != null) {
      futureRoom =
          ChatService.instance.getOrCreateSingleChatRoom(widget.user!.uid);
    } else {
      room = widget.room;
      ChatService.instance.resetNoOfNewMessage(room: widget.room!);
      ChatService.instance.clearLastMessage();
      // If it is a group chat, then check if it's open room and if so, check if the user is a member of the room.
      if (room!.open && room!.users.contains(my.uid) == false) {
        futureRoomJoin = room!.join();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (futureRoomJoin != null) {
      return FutureBuilder<void>(
        future: futureRoomJoin!,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            chatRoom(widget.room!);
          }
          return loadingChatRoom();
        },
      );
    }
    if (room != null) {
      return chatRoom(room!);
    }
    return FutureBuilder<Room>(
      future: futureRoom!,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          chatRoom(snapshot.data!);
        }
        return loadingChatRoom();
      },
    );
  }

  chatRoom(Room room) {
    return Scaffold(
      appBar:
          ChatService.instance.customize.chatRoomAppBarBuilder?.call(room) ??
              ChatRoomAppBar(room: room),
      body: Column(
        children: [
          Expanded(
            child: ChatRoomMessageListView(
              room: room,
            ),
          ),
          ChatRoomMessageBox(room: room),
        ],
      ),
    );
  }

  loadingChatRoom() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user?.name ?? widget.room?.name ?? "Loading..."),
      ),
      body: const SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Loading...'),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
