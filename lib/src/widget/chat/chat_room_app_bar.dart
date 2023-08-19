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
  String title = '';
  List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ChatService.instance.roomDoc(widget.room.id).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        //
        if (snapshot.connectionState == ConnectionState.waiting) {
          title = 'Loading...';
        } else if (snapshot.hasError) {
          //
          title = snapshot.error.toString();
        } else {
          //
          final Room room = Room.fromDocumentSnapshot(snapshot.data!);
          title = room.name;
          actions = [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                return ChatService.instance.openChatRoomMenuDialog(context: context, room: widget.room);
              },
            ),
          ];
        }
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
          actions: actions,
        );
      },
    );
  }
}
