import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// Message List
///
/// This is a widget that will show the list of messages in a room.
/// It does not depend on [ChatService.instance.currentRoom]
class RChatMessageList extends StatefulWidget {
  const RChatMessageList({
    super.key,
    required this.room,
    this.builder,
    this.primary,
    this.emptyBuilder,
  });

  final ChatRoomModel room;

  final Widget Function(ChatMessageModel)? builder;
  final bool? primary;
  final Widget Function(BuildContext)? emptyBuilder;

  @override
  State<RChatMessageList> createState() => _RChatMessageListState();
}

class _RChatMessageListState extends State<RChatMessageList> {
  Widget? resultingWidget;

  String get roomId => widget.room.id;

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      /// We make the pageSize big so that it will fetch less, and less flickering.
      pageSize: 100,
      query: ChatService.instance.messageRef(roomId: roomId).orderByChild('order'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          /// FirebaseDatabaseQueryBuilder will set snapshot.isFetcing only one time when it is first loading.
          // dog('isFetcing');
          //
          ChatService.instance.resetMyRoomNewMessage(room: widget.room);

          if (resultingWidget != null) return resultingWidget!;
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        if (ChatService.instance.isLoadingNewMessage(roomId, snapshot)) {
          final newMessage = ChatMessageModel.fromSnapshot(snapshot.docs.first);
          // newMessage 리셋
          ChatService.instance.resetMyRoomNewMessage(
            room: widget.room,
            order: newMessage.createdAt != null ? -newMessage.createdAt! : null,
          );
        }

        if (snapshot.docs.isEmpty) {
          resultingWidget = widget.emptyBuilder?.call(context) ??
              const Center(child: Text('There is no message, yet.'));
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
              final message = ChatMessageModel.fromSnapshot(snapshot.docs[index]);

              /// Reset the [order] field of the message to list in time based order.
              ChatService.instance.resetRoomMessageOrder(roomId: roomId, order: message.order);

              return ChatBubble(
                message: message,
              );
            },
          );
        }
        return resultingWidget!;
      },
    );
  }
}
