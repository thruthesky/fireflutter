import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Default Chat Room List Screen
///
/// Copy this code to your project and modify it.
///
/// [empty] is the widget to display when there is no chat room.
///
class DefaultChatRoomListView extends StatelessWidget {
  const DefaultChatRoomListView({super.key, this.empty});

  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return MyDocReady(
      builder: (my) => FirebaseDatabaseQueryBuilder(
        query: ChatService.instance.joinsRef
            .child(myUid!)
            .orderByChild(Field.order)
            .startAt(false),
        pageSize: 50,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }
          if (snapshot.hasMore == false && snapshot.docs.isEmpty) {
            return empty ?? const Center(child: Text('No chat rooms'));
          }
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }
              final room = ChatRoom.fromSnapshot(snapshot.docs[index]);
              return ChatRoomListTile(room: room);
            },
          );
        },
      ),
    );
  }
}
