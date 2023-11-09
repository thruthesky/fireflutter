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
  State<ChatRoomMessageListView> createState() => _ChatRoomMessageListViewState();
}

class _ChatRoomMessageListViewState extends State<ChatRoomMessageListView> {
  get chatMessageQuery => messageCol(widget.roomId).orderBy('createdAt', descending: true);

  final paegSize = 40;

  @override
  Widget build(BuildContext context) {
    // Load all users first in the room as a map

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: FirestoreQueryBuilder(
        pageSize: paegSize,
        query: chatMessageQuery,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }

          return ListView.builder(
            reverse: true,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }

              final doc = snapshot.docs[index];

              final message = Message.fromDocumentSnapshot(doc);
              ChatService.instance.setLastMessage(message);

              final messageTile = ChatRoomMessageListViewTile(
                key: Key('message_${message.id}'),
                message: message,
              );

              if (snapshot.docs.length < paegSize && index == snapshot.docs.length - 1) {
                return Column(
                  children: [
                    const Text("Display whtever you want here"),
                    messageTile,
                  ],
                );
              }

              return messageTile;
            },
          );
        },
      ),
    );
  }
}
