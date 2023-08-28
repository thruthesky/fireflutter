import 'package:fireflutter/fireflutter.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomMessageListView extends StatefulWidget {
  const ChatRoomMessageListView({super.key, required this.room});

  final Room room;

  @override
  State<ChatRoomMessageListView> createState() => _ChatRoomMessageListViewState();
}

class _ChatRoomMessageListViewState extends State<ChatRoomMessageListView> {
  @override
  Widget build(BuildContext context) {
    final chatMessageQuery = ChatService.instance.messageCol(widget.room.id).orderBy('createdAt', descending: true);

    // Load all users first in the room as a map

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: FirestoreListView(
        reverse: true,
        query: chatMessageQuery,
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          final message = Message.fromDocumentSnapshot(doc);
          ChatService.instance.setLastMessage(message);
          return ChatRoomMessageListItem(message: message);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
