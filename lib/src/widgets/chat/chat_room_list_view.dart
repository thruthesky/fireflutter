import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChatRoomListViewController {
  late final ChatRoomListViewState state;

  ///
  showChatRoom({required BuildContext context, User? user, ChatRoomModel? room}) {
    ChatService.instance.showChatRoom(context: context, user: user, room: room);
  }
}

/// ChatRoomListView
///
/// It uses [FirestoreListView] to show the list of chat rooms which uses [ListView] internally.
/// And it supports some(not all) of the ListView properties.
///
/// Note that, the controller of ListView is named [scrollController] in this class.
class ChatRoomListView extends StatefulWidget {
  const ChatRoomListView({
    super.key,
    required this.controller,
    this.itemBuilder,
    this.emptyBuilder,
    this.pageSize = 10,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  });

  final ChatRoomListViewController controller;
  final int pageSize;
  final Widget Function(BuildContext, ChatRoomModel)? itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  // final void Function(ChatRoomModel) onTap;

  @override
  State<ChatRoomListView> createState() => ChatRoomListViewState();
}

class ChatRoomListViewState extends State<ChatRoomListView> {
  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    if (ChatService.instance.loggedIn == false) {
      return Center(child: Text(tr.user.loginFirst));
    }
    // Returning a List View of Chat Rooms
    return FirestoreListView(
      query: ChatService.instance.chatCol
          .where('users', arrayContains: ChatService.instance.uid)
          .orderBy('lastMessage.createdAt', descending: true),
      itemBuilder: (context, QueryDocumentSnapshot snapshot) {
        final room = ChatRoomModel.fromDocumentSnapshot(snapshot);
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(context, room);
        } else {
          return ChatRoomListTile(room: room);
        }
      },
      emptyBuilder: (context) {
        if (widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
        } else {
          return Center(child: Text(tr.chat.noChatRooms));
        }
      },
      errorBuilder: (context, error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return Center(child: Text('Error loading chat rooms $error'));
      },
      pageSize: widget.pageSize,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      clipBehavior: widget.clipBehavior,
    );
  }
}
