import 'package:fireflutter/src/models/message.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/src/widgets/chat/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessagesListView extends StatelessWidget {
  const ChatMessagesListView({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    debugPrint("Rebuildinghere?");
    final query = ChatService.instance.messageCol(room.id).orderBy('createdAt', descending: true);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FirestoreListView(
        // TODO ask for help because the app makes weird movement upon scrolling up
        // ! Please NOTICE
        reverse: true,
        query: query,
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          debugPrint("Rebuilding?");
          return ChatMessageBubble(chatMessage: Message.fromDocumentSnapshot(doc));
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
