import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRoomOpenGroupListView extends StatelessWidget {
  const ChatRoomOpenGroupListView({
    super.key,
    this.itemBuilder,
  });

  final Widget Function(BuildContext, Room)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final query = chatCol.where('open', isEqualTo: true).where('group', isEqualTo: true);
    return FirestoreListView(
      query: query,
      itemBuilder: (BuildContext context, QueryDocumentSnapshot snapshot) {
        final room = Room.fromDocumentSnapshot(snapshot);
        if (itemBuilder != null) {
          return itemBuilder!(context, room);
        } else {
          return ChatRoomListTile(
            room: room,
            onTap: () => ChatService.instance.showChatRoom(context: context, room: room),
          );
        }
      },
    );
  }
}
