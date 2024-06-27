import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enum for what chat rooms to display.
enum ChatRoomList {
  /// [my] means the chat rooms that I belong, whether 1:1 or group
  my,

  /// [single] means the chat rooms for 1:1
  single,

  /// [group] means the group chat rooms that I belong
  group,

  /// [open] means the open group chat room whether I belong or not
  open,

  /// [domain] means the open group chat room in a specific domain
  domain,
}

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
    // this.openChat = false,
    this.chatRoomList = ChatRoomList.my,
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
    this.itemPadding,
  });

  // final bool openChat;
  final ChatRoomList chatRoomList;

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
  final EdgeInsetsGeometry? itemPadding;

  DatabaseReference get _joinsRef => ChatService.instance.joinsRef;

  Query get _queryFromChatRoomList => switch (chatRoomList) {
        ChatRoomList.my =>
          _joinsRef.child(myUid!).orderByChild(Field.order).startAt(false),
        ChatRoomList.single => _joinsRef
            .child(myUid!)
            .orderByChild(Field.singleChatOrder)
            .startAt(false),
        ChatRoomList.group => _joinsRef
            .child(myUid!)
            .orderByChild(Field.groupChatOrder)
            .startAt(false),
        ChatRoomList.open => ChatService.instance.roomsRef
            .orderByChild(Field.openGroupChatOrder)
            .startAt(false),
        ChatRoomList.domain => ChatService.instance.roomsRef
            .orderByChild(Field.domainChatOrder)
            .startAt(false),
      };

  @override
  Widget build(BuildContext context) {
    return DocReady(
      builder: (my) => FirebaseDatabaseQueryBuilder(
        query: query ?? _queryFromChatRoomList,
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

              return Padding(
                  padding: itemPadding ?? const EdgeInsets.all(0),
                  child: itemBuilder?.call(room, index) ??
                      ChatRoomListTile(room: room));
            },
          );
        },
      ),
    );
  }
}
