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
  final Widget Function(BuildContext, Room)? itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
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
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, room);
        } else {
          return room.isSingleChat
              // Kindly review
              // for issue https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40781402
              ? UserBlocked(
                  otherUid: room.otherUserUid,
                  blockedBuilder: (context) {
                    return const Text("*** Blocked ***");
                  },
                  notBlockedBuilder: (context) {
                    return ChatRoomListTile(
                      key: ValueKey(room.roomId),
                      room: room,
                      avatarSize: widget.avatarSize,
                      onTap: () {
                        widget.onTap?.call(room) ?? ChatService.instance.showChatRoom(context: context, room: room);
                      },
                    );
                  },
                )
              : chatRoomListTile(room, context);
        }
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

  ChatRoomListTile chatRoomListTile(Room room, BuildContext context) {
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
