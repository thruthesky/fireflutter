import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/rchat/rchat.bubble.dart';
import 'package:flutter/material.dart';

class RChatMessageList extends StatefulWidget {
  const RChatMessageList({
    super.key,
    required this.roomId,
    this.builder,
  });

  final String roomId;
  final Widget Function(RChatMessageModel)? builder;

  @override
  State<RChatMessageList> createState() => _RChatMessageListState();
}

class _RChatMessageListState extends State<RChatMessageList> {
  Widget? list;
  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      pageSize: 20,
      query: chatMessageRef(roomId: widget.roomId).orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          print(
            '--> FirebaseDatabaseQueryBuilder will set snapshot.isFetcing only one time when it is first loading.',
          );
          if (list != null) return list!;
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        list = ListView.builder(
          reverse: true,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }
            final message = RChatMessageModel.fromSnapshot(snapshot.docs[index]);

            resetChatRoomMessageOrder(roomId: widget.roomId, order: message.order);

            return RChatBubble(
              message: message,
            );
          },
        );

        return list!;
      },
    );
  }
}
