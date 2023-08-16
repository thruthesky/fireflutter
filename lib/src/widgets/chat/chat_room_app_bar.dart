import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/room.dart';
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
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> roomStream = ChatService.instance.roomDoc(widget.room.id).snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: roomStream,
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Something went wrong.'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Loading..."),
          );
        }
        final Room roomSnapshot = Room.fromDocumentSnapshot(snapshot.data!);
        return AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: ChatRoomAppBarTitle(room: roomSnapshot),
          actions: [
            ChatRoomMenuButton(
              room: roomSnapshot,
            ),
          ],
        );
      },
    );
  }
}
