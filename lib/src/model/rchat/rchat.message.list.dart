import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/rchat/rchat.bubble.dart';
import 'package:flutter/material.dart';

class RChatMessageList extends StatefulWidget {
  const RChatMessageList({
    super.key,
    required this.roomId,
    this.builder,
    this.primary,
    this.emptyBuilder,
  });

  final String roomId;
  final Widget Function(RChatMessageModel)? builder;
  final bool? primary;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<RChatMessageList> createState() => _RChatMessageListState();
}

class _RChatMessageListState extends State<RChatMessageList> {
  Widget? resultingWidget;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      /// We make the pageSize big so that it will fetch less, and less flickering.
      pageSize: 100,
      query: RChat.messageRef(roomId: widget.roomId).orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          /// FirebaseDatabaseQueryBuilder will set snapshot.isFetcing only one time when it is first loading.
          dog('isFetcing ${widget.roomId}');

          // RChat.resetRoomNewMessage(roomId: widget.roomId);
          _resetNewMessage();

          if (resultingWidget != null) return resultingWidget!;
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }
        if (RChat.isLoadingForNewMessage(widget.roomId, snapshot)) {
          dog('isFetcing  still ${widget.roomId}');

          /// newMessage 리셋
          // Do not reset the newMessage here because
          // we don't know if the room is a single chat or group chat.
          // RChat.resetRoomNewMessage(roomId: widget.roomId);
        }

        if (snapshot.docs.isEmpty) {
          resultingWidget = widget.emptyBuilder?.call(context) ?? Center(child: Text(tr.noMessageYet));
        } else {
          /// Reset the newMessage
          /// This is a good place to reset it since it is called when the user
          /// enters the room and every time it gets new message.
          resultingWidget = ListView.builder(
            padding: const EdgeInsets.all(0),
            reverse: true,
            primary: widget.primary,
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
        }

        _resetNewMessage();
        return resultingWidget!;
      },
    );
  }

  void _resetNewMessage() {
    RChatRoomModel.fromRoomId(widget.roomId).then((room) {
      if (room.isExists == false) return;
      if (room.isGroupChat ?? true) {
        RChat.resetRoomNewMessage(roomId: widget.roomId);
      }
    });
  }
}
