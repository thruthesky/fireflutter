import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class AdminChatRoomListScreen extends StatefulWidget {
  static const String routeName = '/AdminChatRoomList';
  const AdminChatRoomListScreen({super.key});

  @override
  State<AdminChatRoomListScreen> createState() => _AdminChatRoomListScreenState();
}

class _AdminChatRoomListScreenState extends State<AdminChatRoomListScreen> {
  final controller = ChatRoomListViewController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('AdminChatRoomListBackButton'),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Admin Chat Room List'),
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
                children: [ChatRoomListTile(room: room)],
              ),
            ),
          );
        },
      ),
    );
  }
}
