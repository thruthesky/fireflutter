import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/rchat/rchat.bubble.dart';
import 'package:flutter/material.dart';

class RChatMessageList extends StatefulWidget {
  const RChatMessageList({super.key, required this.roomId, this.builder});

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
      query: RChat.messageRef(roomId: widget.roomId).orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          /// FirebaseDatabaseQueryBuilder will set snapshot.isFetcing only one time when it is first loading.
          dog('isFetcing');

          RChat.resetRoomNewMessage(roomId: widget.roomId);

          if (list != null) return list!;
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        if (RChat.isLoadingForNewMessage(widget.roomId, snapshot)) {
          /// newMessage 리셋
          RChat.resetRoomNewMessage(roomId: widget.roomId);
        }

        /// Reset the newMessage
        /// This is a good place to reset it since it is called when the user
        /// enters the room and every time it gets new message.

        list = ListView.builder(
          padding: const EdgeInsets.all(0),
          reverse: true,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              snapshot.fetchMore();
            }
            final message = RChatMessageModel.fromSnapshot(snapshot.docs[index]);

            RChat.resetRoomMessageOrder(roomId: widget.roomId, order: message.order);

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
