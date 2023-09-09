import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/src/model/chat/room.dart';
import 'package:fireflutter/src/service/chat.service.dart';
import 'package:fireflutter/src/widget/chat/chat_room_list_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomOpenListView extends StatelessWidget {
  const ChatRoomOpenListView({
    super.key,
    this.itemBuilder,
  });

  final Widget Function(BuildContext, Room)? itemBuilder;

  @override
  Widget build(BuildContext context) {
    final query = ChatService.instance.chatCol
        .where('open', isEqualTo: true)
        .where('group', isEqualTo: true);
    return FirestoreListView(
      query: query,
      itemBuilder: (BuildContext context, QueryDocumentSnapshot snapshot) {
        final room = Room.fromDocumentSnapshot(snapshot);
        if (itemBuilder != null) {
          return itemBuilder!(context, room);
        } else {
          return ChatRoomListTile(
            room: room,
            onTap: () =>
                ChatService.instance.showChatRoom(context: context, room: room),
          );
        }
      },
    );
  }
}
