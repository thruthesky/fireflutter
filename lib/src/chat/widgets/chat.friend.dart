import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatFriend extends StatefulWidget {
  const ChatFriend({
    Key? key,
    required this.uid,
    required this.builder,
  }) : super(key: key);

  final String uid;
  final Widget Function(bool?) builder;

  @override
  State<ChatFriend> createState() => _ChatFriendState();
}

class _ChatFriendState extends State<ChatFriend> {
  DocumentSnapshot? snapshot;
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    /// Somehow, uid becomes empty string.
    if (widget.uid != "") {
      sub = ChatBase.myRoomsCol.doc(widget.uid).snapshots().listen((event) {
        if (mounted) {
          setState(() {
            snapshot = event;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Somehow, widget.uid becomes empty stirng.
    if (widget.uid == "") return SizedBox.shrink();

    if (UserService.instance.notSignedIn || snapshot == null)
      return widget.builder(null);

    bool isFriend;
    if (snapshot?.exists == false) {
      isFriend = false;
    } else {
      final room = ChatMessageModel.fromJson(
          snapshot?.data() as Map, snapshot?.reference);
      isFriend = room.friend;
    }

    return widget.builder(isFriend);
  }
}
