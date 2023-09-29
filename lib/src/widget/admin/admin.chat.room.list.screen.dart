import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminChatRoomListScreen extends StatefulWidget {
  static const String routeName = '/AdminChatRoomList';
  const AdminChatRoomListScreen({super.key});

  @override
  State<AdminChatRoomListScreen> createState() =>
      _AdminChatRoomListScreenState();
}

class _AdminChatRoomListScreenState extends State<AdminChatRoomListScreen> {
  final controller = ChatRoomListViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text('Admin Chat Room List',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface)),
      ),
      body: FirestoreListView(
        query: chatCol,
        itemBuilder: (context, snapshot) {
          final room = Room.fromDocumentSnapshot(snapshot);
          return InkWell(
            onTap: () {
              AdminService.instance.showChatRoomDetails(context, room: room);
            },
            child: Padding(
              padding: const EdgeInsets.all(sizeSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    room.roomId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (room.name.isNotEmpty)
                    Text('Chat Room Name: ${room.name}'),
                  Text(
                      'Last Activity: ${room.lastMessage?.createdAt ?? room.createdAt}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
