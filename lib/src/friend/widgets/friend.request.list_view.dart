import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/friend/widgets/friend.request.list_tile.dart';
import 'package:fireflutter/src/friend/widgets/friend.sent.list_tile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum FriendRequestList {
  /// The list for the requests that was received.
  ///
  /// Coming from `friends-requests-received/{uid}/...`
  received,

  /// The list for the requests that was sent.
  ///
  /// Coming from `friends-requests-sent/{uid}/...`
  sent,
}

class FriendRequestListView extends StatelessWidget {
  FriendRequestListView({
    super.key,
    this.list = FriendRequestList.received,
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
  });

  final FriendRequestList list;
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
  final Widget Function(Friend, int)? itemBuilder;

  Query get _query => switch (list) {
        FriendRequestList.received => Friend.myReceivedRequestListRef,
        FriendRequestList.sent => Friend.mySentRequestListRef,
      };

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
        query: _query,
        builder: (context, snapshot, widget) {
          if (snapshot.isFetching) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            dog('Error: ${snapshot.error}');
            return Text('Something went wrong! ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.docs.isEmpty && !snapshot.hasMore) {
            return const Center(
                child: Text('@TODO - Display empty list message'));
          }

          return ListView.separated(
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
            padding: padding,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            cacheExtent: cacheExtent,
            dragStartBehavior: dragStartBehavior,
            keyboardDismissBehavior: keyboardDismissBehavior,
            restorationId: restorationId,
            clipBehavior: clipBehavior,
            itemBuilder: (context, index) {
              // if we reached the end of the currently obtained items, we try to
              // obtain more items
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
                // It is safe to call this function from within the build method.
                snapshot.fetchMore();
              }

              final friend = Friend.fromSnapshot(snapshot.docs[index]);
              if (itemBuilder != null) {
                return itemBuilder!(friend, index);
              }
              if (list == FriendRequestList.received) {
                return FriendRequestReceivedListTile(
                  friend: friend,
                );
              } else {
                return FriendRequestSentListTile(
                  friend: friend,
                );
              }
            },
          );
        });
  }
}
