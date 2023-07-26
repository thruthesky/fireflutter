import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomOpenListView extends StatelessWidget {
  const ChatRoomOpenListView({
    super.key,
    this.itemBuilder,
  });

  final Widget Function(BuildContext, ChatRoomModel)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final query = EasyChat.instance.chatCol.where('open', isEqualTo: true).where('group', isEqualTo: true);
    return FirestoreListView(
      query: query,
      itemBuilder: (BuildContext context, QueryDocumentSnapshot snapshot) {
        final room = ChatRoomModel.fromDocumentSnapshot(snapshot);
        if (itemBuilder != null) {
          return itemBuilder!(context, room);
        } else {
          return ChatRoomListTile(
            room: room,
            joinOnEnter: true,
          );
        }
      },
    );
  }
}
