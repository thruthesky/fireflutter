import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  createState() => ChatRoomAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class ChatRoomAppBarState extends State<ChatRoomAppBar> {
  late Room room;

  List<Widget>? actions;

  @override
  void initState() {
    super.initState();
    room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ChatService.instance.roomDoc(widget.room.id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // error
        if (snapshot.hasError) {
          return AppBar(title: Text(snapshot.error.toString()));
        }

        // Got the chat room data? or use the param data.
        if (snapshot.hasData) {
          room = Room.fromDocumentSnapshot(snapshot.data!);
        }

        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: room.isGroupChat ? Text(room.name) : UserDoc(builder: (user) => Text(user.name)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                return ChatService.instance.openChatRoomMenuDialog(context: context, room: widget.room);
              },
            ),
          ],
        );
      },
    );
  }
}
