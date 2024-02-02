import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DefaultChatListScreen extends StatelessWidget {
  static const String defaultRouteName = '/ChatList';
  const DefaultChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chat Rooms'),
        actions: [
          IconButton(
            onPressed: () {
              ChatService.instance.showChatRoomCreate(context: context);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FirebaseDatabaseQueryBuilder(
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
              return const Text('No chat rooms');
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                  snapshot.fetchMore();
                }
                final room = ChatRoomModel.fromSnapshot(snapshot.docs[index]);
                return ChatRoomListTile(room: room);
              },
            );
          },
        ),
      ),
    );
  }
}
