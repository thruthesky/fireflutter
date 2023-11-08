import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// FeedLsitView
///
/// Displays feed list with pagination.
///
/// ```dart
/// FeedListView(
///  pageSize: 20,
/// itemBuilder: (feed, index) {
///  return ListTile(
///   title: Text(feed.title),
///  subtitle: Text(feed.body),
/// );
/// },
/// );
/// ```
class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    this.pageSize = 20,
    this.itemExtent,
    this.cacheExtent,
    required this.itemBuilder,
    this.avatarBuilder,
    this.topBuilder,
    this.textBuilder,
    this.bottomBuilder,
    this.emptyBuilder,
    this.query,
    this.onTap,
  });

  final int pageSize;
  final double? itemExtent;
  final double? cacheExtent;
  final Widget Function(Post feed, int index) itemBuilder;

  /// Removed the isFullPage because there was two bugs.
  /// 1. the value is not correct.
  /// 2. it's not working as expected. It provides more information than what is needed.
  final Widget Function(Post feed)? topBuilder;

  final Widget Function(BuildContext, Post)? avatarBuilder;
  final Widget Function(BuildContext, Post)? textBuilder;
  final Widget Function(BuildContext context)? bottomBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  final Query? query;

  final void Function(Post)? onTap;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  @override
  void initState() {
    super.initState();
    UserService.instance.documentChanges.listen((user) {
      if (user == null) return;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreQueryBuilder(
      query: widget.query ?? postCol.where('followers', arrayContains: myUid).orderBy('createdAt', descending: true),
      pageSize: widget.pageSize,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          dog(snapshot.error.toString());
          return Text('Something went wrong! ${snapshot.error}');
        }
        if (snapshot.docs.isEmpty) {
          // means has no more to get
          if (widget.emptyBuilder != null) return widget.emptyBuilder!.call(context);
        }
        return ListView.builder(
          /// EdgeInsets.zero is important to avoid unexpected padding for sliver NestScrollView.
          padding: EdgeInsets.zero,
          physics: const RangeMaintainingScrollPhysics(),
          itemExtent: widget.itemExtent,
          cacheExtent: widget.cacheExtent,
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            // if we reached the end of the currently obtained items, we try to
            // obtain more items
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirebaseDatabaseQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
            }
            if ((!snapshot.hasMore && index + 1 == snapshot.docs.length)) {
              // means has no more to get
              if (widget.bottomBuilder != null) return widget.bottomBuilder!.call(context);
            }
            final post = Post.fromDocumentSnapshot(snapshot.docs[index]);
            final child = widget.itemBuilder.call(post, index);
            if (widget.topBuilder != null && index == 0) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.topBuilder!.call(post),
                  child,
                ],
              );
            }
            return child;
          },
        );
      },
    );
  }
}
