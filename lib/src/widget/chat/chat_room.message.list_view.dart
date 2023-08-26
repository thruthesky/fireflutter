import 'package:fireflutter/fireflutter.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomMessageListView extends StatelessWidget {
  const ChatRoomMessageListView({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final chatMessageQuery = ChatService.instance.messageCol(room.id).orderBy('createdAt', descending: true);

    // Load all users first in the room as a map

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FirestoreListView(
        reverse: true,
        query: chatMessageQuery,
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          return ChatRoomMessageListItem(message: Message.fromDocumentSnapshot(doc));
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
