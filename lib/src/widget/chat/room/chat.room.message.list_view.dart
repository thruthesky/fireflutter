import 'package:fireflutter/fireflutter.dart';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomMessageListView extends StatefulWidget {
  const ChatRoomMessageListView({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  State<ChatRoomMessageListView> createState() =>
      _ChatRoomMessageListViewState();
}

class _ChatRoomMessageListViewState extends State<ChatRoomMessageListView> {
  get chatMessageQuery => ChatService.instance
      .messageCol(widget.roomId)
      .orderBy('createdAt', descending: true);

  @override
  Widget build(BuildContext context) {
    // Load all users first in the room as a map

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: FirestoreListView(
        reverse: true,
        query: chatMessageQuery,
        itemBuilder:
            (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          final message = Message.fromDocumentSnapshot(doc);
          ChatService.instance.setLastMessage(message);
          return ChatRoomMessageListViewTile(message: message);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
