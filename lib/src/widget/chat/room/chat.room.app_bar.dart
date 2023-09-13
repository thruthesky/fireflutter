import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({
    super.key,
    this.room,
    this.user,
  });

  final Room? room;
  final User? user;

  @override
  createState() => ChatRoomAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class ChatRoomAppBarState extends State<ChatRoomAppBar> {
  List<Widget>? actions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.room != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: ChatService.instance.roomDoc(widget.room!.roomId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          late Room room;
          // error
          if (snapshot.hasError) {
            return AppBar(title: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            room = widget.room!;
          } else

          // Got the chat room data? or use the param data.
          if (snapshot.hasData) {
            room = Room.fromDocumentSnapshot(snapshot.data!);
          }

          return AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: room.isGroupChat
                ? Text(room.name)
                : UserDoc(
                    builder: (user) => Text(user.name),
                    uid: otherUserUid(room.users),
                    live: false,
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  return ChatService.instance
                      .openChatRoomMenuDialog(context: context, room: room);
                },
              ),
            ],
          );
        },
      );
    } else if (widget.user != null) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.user!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              return ChatService.instance
                  .openChatRoomMenuDialog(context: context, room: widget.room!);
            },
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
