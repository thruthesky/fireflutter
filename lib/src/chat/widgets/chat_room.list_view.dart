import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Chat Room List View
///
/// Displays the list of chat rooms.
///
/// [empty] is the widget to display when there is no chat room.
///
/// This supports most of the parameters of ListView.
///
class ChatRoomListView extends StatelessWidget {
  const ChatRoomListView({
    super.key,
    this.openChat = false,
    this.query,
    this.pageSize = 10,
    this.loadingBuilder,
    this.errorBuilder,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.itemBuilder,
    this.emptyBuilder,
  });

  final bool openChat;
  final Query? query;
  final int pageSize;
  final Widget Function()? loadingBuilder;
  final Widget Function(String)? errorBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final Widget Function(ChatRoom, int)? itemBuilder;
  final Widget Function()? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return DocReady(
      builder: (my) => FirebaseDatabaseQueryBuilder(
        query: openChat
            ? ChatService.instance.roomsRef
                .orderByChild(Field.openGroupChatOrder)
                .startAt(false)
            : (query ??
                ChatService.instance.joinsRef
                    .child(myUid!)
                    .orderByChild(Field.order)
                    .startAt(false)),
        pageSize: 50,
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return loadingBuilder?.call() ??
                const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            dog('Error: ${snapshot.error}');
            return errorBuilder?.call(snapshot.error.toString()) ??
                Text('Something went wrong! ${snapshot.error}');
          }

          if (snapshot.hasMore == false && snapshot.docs.isEmpty) {
            return emptyBuilder?.call() ??
                Center(child: Text(T.thereIsNoChatRoomInChatRoomListView.tr));
          }

          return ListView.separated(
            padding: padding,
            itemCount: snapshot.docs.length,
            separatorBuilder: (context, index) =>
                separatorBuilder?.call(context, index) ??
                const SizedBox.shrink(),
            scrollDirection: scrollDirection,
            reverse: reverse,
            controller: controller,
            primary: primary,
            physics: physics,
            shrinkWrap: shrinkWrap,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            cacheExtent: cacheExtent,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }
              final room = ChatRoom.fromSnapshot(snapshot.docs[index]);

              return itemBuilder?.call(room, index) ??
                  ChatRoomListTile(room: room);
            },
          );
        },
      ),
    );
  }
}
