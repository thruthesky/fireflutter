import 'package:fireflutter/src/models/chat_message_model.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/src/widgets/chat/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessagesListView extends StatefulWidget {
  const ChatMessagesListView({super.key, required this.room});

  final ChatRoomModel room;

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesViewState();
}

class _ChatMessagesViewState extends State<ChatMessagesListView> {
  @override
  Widget build(BuildContext context) {
    final query = ChatService.instance
        .messageCol(widget.room.id)
        .orderBy('createdAt', descending: true);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FirestoreListView(
        reverse: true,
        query: query,
        itemBuilder:
            (BuildContext context, QueryDocumentSnapshot<dynamic> doc) {
          return ChatMessageBubble(
              chatMessage: ChatMessageModel.fromDocumentSnapshot(doc));
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint(error.toString());
          return Text(error.toString());
        },
      ),
    );
  }
}
