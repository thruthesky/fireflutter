import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChatRoomListViewController {
  ChatRoomListViewState? state;

  ///
  showChatRoom({required BuildContext context, User? user, Room? room}) {
    ChatService.instance.showChatRoom(context: context, user: user, room: room);
  }
}

/// ChatRoomListView
///
/// It uses [FirestoreListView] to show the list of chat rooms which uses [ListView] internally.
/// And it supports some(not all) of the ListView properties.
///
/// Note that, the controller of ListView is named [scrollController] in this class.
///
/// [singleChatOnly] If [singleChatOnly] is set to true, it will only list single chat rooms.
///
/// [groupChatOnly] If [groupChatOnly] is set to true, it will only list group chat rooms.
///
/// [openChatOnly] If [openChatOnly] is set to true, it will only list open chat rooms.
///
/// [itemExtent] If you want to set the height of each item, use [itemExtent].
/// It is the same as [ListView.itemExtent]. Default is 68. It can be a null.
///
/// [visibility] If you want to hide the list, set [visibility] to false.
/// Note that, if you set [itemExtent] and [visibility] together, it will not
/// work and an assertion will happen.
///
class ChatRoomListView extends StatefulWidget {
  const ChatRoomListView({
    super.key,
    this.controller,
    this.orderBy = 'lastMessage.createdAt',
    this.descending = true,
    this.itemBuilder,
    this.blockedBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    this.chatRoomAppBarBuilder,
    this.singleChatOnly = false,
    this.groupChatOnly = false,
    this.openChatOnly = false,
    this.allChat = false,
    this.itemExtent = 64,
    this.avatarSize = 46,
    this.scrollDirection = Axis.vertical,
    this.visibility,
    this.onTap,
  }) : assert(itemExtent == null || visibility == null, "You can't set both itemExtent and visibility");

  final ChatRoomListViewController? controller;
  final String orderBy;
  final bool descending;
  final int pageSize;

  /// [itemBuilder] is used to build each item of the list.
  final Widget Function(BuildContext context, Room room)? itemBuilder;

  /// [blockedBuilder] is used to show when you have blocked the user in a single chat room.
  /// group chat rooms will not be affected.
  /// by default, it will use simply itemBuilder.
  final Widget Function(BuildContext context, Room room)? blockedBuilder;

  /// [emptyBuilder] is used to show when there is no chat room.
  /// meaning no result from the query.
  final Widget Function(BuildContext context)? emptyBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  final bool singleChatOnly;
  final bool groupChatOnly;
  final bool openChatOnly;

  /// [allChat] if [allChat] is set to true, then it will list all the chat room. Only admin can do this.
  final bool allChat;

  final double? itemExtent;

  final double avatarSize;

  final Axis scrollDirection;

  final bool Function(Room)? visibility;

  final Function(Room)? onTap;

  /// If you want to customize the app bar of chat room, you can use this builder.
  /// If you return null, the default app bar will be used.
  final PreferredSizeWidget Function(BuildContext, Room)? chatRoomAppBarBuilder;

  @override
  State<ChatRoomListView> createState() => ChatRoomListViewState();
}

class ChatRoomListViewState extends State<ChatRoomListView> {
  @override
  void initState() {
    super.initState();
    widget.controller?.state = this;
  }

  Query get query {
    Query q = chatCol;

    // Display all open chat room
    if (widget.allChat) {
      // pass all other fitlering if [allChat] is set.
    } else if (widget.openChatOnly == true) {
      q = q.where('open', isEqualTo: true);
    } else {
      // Or display all of my rooms
      q = q.where('users', arrayContains: myUid!);

      // and Display 1:1 chat rooms of my rooms
      if (widget.singleChatOnly == true) {
        q = q.where('group', isEqualTo: false);
      } else
      // Or display group chat rooms of my rooms
      if (widget.groupChatOnly == true) {
        q = q.where('group', isEqualTo: true);
      }
    }

    q = q.orderBy(widget.orderBy, descending: widget.descending);
    return q;
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == false) {
      return Center(child: Text(tr.loginFirstMessage));
    }
    return FirestoreListView(
      query: query,
      itemExtent: widget.itemExtent,
      itemBuilder: (context, QueryDocumentSnapshot snapshot) {
        final room = Room.fromDocumentSnapshot(snapshot);
        if (widget.visibility != null && widget.visibility!(room) == false) {
          return const SizedBox();
        }
        return _chatRoomListItem(room, context);
      },
      emptyBuilder: (context) {
        if (widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        } else {
          return Center(child: Text(tr.noChatRooms));
        }
      },
      errorBuilder: (context, error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return Center(child: Text('Error loading chat rooms $error'));
      },
      loadingBuilder: (context) => const Center(child: CircularProgressIndicator()),
      pageSize: widget.pageSize,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
      scrollDirection: widget.scrollDirection,
    );
  }

  /// Chat room list item
  /// Return chat room list tile by default.
  /// If [blockedBuilder] is set, it will use [blockedBuilder] to build the list tile.
  /// If [blockedBuilder] is not set, it will use [itemBuilder] to build the list tile.
  /// If [itemBuilder] is set, it will use defaultChatRoomListTile [itemBuilder] to build the list tile.
  Widget _chatRoomListItem(Room room, BuildContext context) {
    // This is to prevent check if block when uneccesarry
    if (widget.blockedBuilder == null || room.isGroupChat) {
      return widget.itemBuilder?.call(context, room) ?? _defaultChatRoomListTile(room, context);
    }
    // Need to review
    // github issue https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=41997149
    return UserBlocked(
      otherUid: room.otherUserUid,
      blockedBuilder: (context) {
        return widget.blockedBuilder!.call(context, room);
      },
      notBlockedBuilder: (context) {
        return widget.itemBuilder?.call(context, room) ?? _defaultChatRoomListTile(room, context);
      },
    );
  }

  /// Default chat room list tile
  ChatRoomListTile _defaultChatRoomListTile(Room room, BuildContext context) {
    return ChatRoomListTile(
      key: ValueKey(room.roomId),
      room: room,
      avatarSize: widget.avatarSize,
      onTap: () {
        widget.onTap?.call(room) ?? ChatService.instance.showChatRoom(context: context, room: room);
      },
    );
  }
}
