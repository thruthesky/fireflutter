import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({
    super.key,
    this.itemExtent,
    this.cacheExtent,
    required this.itemBuilder,
    this.topBuilder,
    this.textBuilder,
    this.avatarBuilder,
    this.onTap,
  });

  final double? itemExtent;
  final double? cacheExtent;
  final Widget Function(Post feed, int index) itemBuilder;
  final Widget Function(Feed feed)? topBuilder;

  final Widget Function(BuildContext, Post)? avatarBuilder;
  final Widget Function(BuildContext, Post)? textBuilder;

  final void Function(Post)? onTap;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  bool noFollowings = false;
  final scrollBarControlller = ScrollController();

  @override
  void initState() {
    super.initState();
    UserService.instance.documentChanges.listen((user) {
      if (user == null) return;
      // Currently, [noFollowings] is only useful when user have not followed anyone.
      // This will prevent rebuilding everytime user has been updated.
      if (noFollowings == user.followings.isEmpty) return;
      noFollowings = user.followings.isEmpty;
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noFollowings) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have not followed anyone'),
          ],
        ),
      );
    }

    return FirebaseDatabaseQueryBuilder(
      query: rtdb.ref('feeds').child(FirebaseAuth.instance.currentUser!.uid).orderByChild('createdAt'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }
        return Scrollbar(
          controller: scrollBarControlller,
          child: ListView.builder(
            controller: scrollBarControlller,
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
              final feed = Feed.fromSnapshot(snapshot.docs[index]);
              final post = Post.fromJson(feed.toJson());

              final child = widget.itemBuilder.call(post, index);

              if (widget.topBuilder != null && index == 0) {
                return Column(
                  children: [
                    widget.topBuilder!.call(feed),
                    child,
                  ],
                );
              }
              return child;
            },
          ),
        );
      },
    );
  }
}
