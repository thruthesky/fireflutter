import 'dart:async';

import 'package:badges/badges.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ChatRooms extends StatefulWidget {
  const ChatRooms({
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.onEmpty,
    Key? key,
  }) : super(key: key);

  final FunctionRoomsItemBuilder itemBuilder;
  final Widget? onEmpty;
  final bool shrinkWrap;

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

enum TabIndex {
  friends,
  youMayKnow,
}

class _ChatRoomsState extends State<ChatRooms> {
  final List<ChatMessageModel> friends = [];
  int friendsMessageCount = 0;
  final List<ChatMessageModel> youMayKnow = [];
  int youMayKnowMessageCount = 0;

  bool firstLoad = false;

  late final StreamSubscription? sub;

  TabIndex tabIndex = TabIndex.friends;

  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    firstLoad = true;
    sub = ChatBase.myRoomsCol.orderBy('timestamp', descending: true).snapshots().listen((snapshot) {
      friends.clear();
      youMayKnow.clear();
      friendsMessageCount = 0;
      youMayKnowMessageCount = 0;
      for (final doc in snapshot.docs) {
        final room = ChatMessageModel.fromJson(doc.data() as Map, doc.reference);
        if (room.friend) {
          friends.add(room);
          friendsMessageCount += room.newMessages;
        } else {
          youMayKnow.add(room);
          youMayKnowMessageCount += room.newMessages;
        }
      }
      setState(() {
        firstLoad = false;
      });
    }, onError: (e) {
      setState(() {
        firstLoad = false;
      });
      throw (e);
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad == true) {
      return Center(
        child: CircularProgressIndicator.adaptive(),
      );
    }

    if (friends.length == 0 && youMayKnow.length == 0) {
      return widget.onEmpty ??
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Text(
                'No friends, yet. Please send a message to some friends.',
              ),
            ),
          );
    }

    return Column(
      children: [
        Container(
          child: Flex(direction: Axis.horizontal, children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => tabIndex = TabIndex.friends),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Friends',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(width: 4),
                    messageCount(friendsMessageCount)
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => tabIndex = TabIndex.youMayKnow),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You may know',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(width: 4),
                    messageCount(youMayKnowMessageCount)
                  ],
                ),
              ),
            ),
          ]),
        ),
        if (tabIndex == TabIndex.friends) friendsWidget else youMayKnowWidget
      ],
    );
  }

  Widget get friendsWidget {
    if (friends.isEmpty)
      return Container(
        child: Text(
          'No friends, yet. Please add some friends. You may check you may know tab.',
          textAlign: TextAlign.center,
        ),
      );
    return Column(
      children: [
        for (final room in friends)
          Container(
            key: ValueKey(room.otherUid),
            child: widget.itemBuilder(room),
          ),
      ],
    );
  }

  Widget get youMayKnowWidget {
    if (youMayKnow.isEmpty)
      return const Center(
        child: Text(
          'Find friends in forum or user search.',
          textAlign: TextAlign.center,
        ),
      );
    return Column(
      children: [
        for (final room in youMayKnow)
          Container(
            key: ValueKey(room.otherUid),
            child: widget.itemBuilder(room),
          ),
      ],
    );
  }

  Widget messageCount(int count) {
    if (count == 0) return SizedBox.shrink();

    return SizedBox(
      width: 20,
      height: 20,
      child: Badge(
        toAnimate: false,
        shape: BadgeShape.circle,
        badgeColor: Colors.red,
        elevation: 0,
        padding: EdgeInsets.all(1.0),
        badgeContent: Center(
          child: Text(count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              )),
        ),
      ),
    );
  }
}
