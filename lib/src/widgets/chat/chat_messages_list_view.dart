<<<<<<< HEAD
import 'package:fireflutter/src/models/message.dart';
import 'package:fireflutter/src/models/room.dart';
import 'package:fireflutter/src/services/chat.service.dart';
=======
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_message_model.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
>>>>>>> messages_wierd_scroll
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessagesListView extends StatelessWidget {
  const ChatMessagesListView({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    debugPrint("Rebuildinghere?");
    final query = ChatService.instance.messageCol(room.id).orderBy('createdAt', descending: true);
=======
    final chatMessageQuery = ChatService.instance.messageCol(room.id).orderBy('createdAt', descending: true);

    // Load all users first in the room as a map

>>>>>>> messages_wierd_scroll
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FirestoreListView(
        reverse: true,
<<<<<<< HEAD
        query: query,
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          debugPrint("Rebuilding?");
          return ChatMessageBubble(chatMessage: Message.fromDocumentSnapshot(doc));
=======
        query: chatMessageQuery,
        itemBuilder: (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          return ChatMessageBubble(chatMessage: ChatMessageModel.fromDocumentSnapshot(doc));
>>>>>>> messages_wierd_scroll
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
