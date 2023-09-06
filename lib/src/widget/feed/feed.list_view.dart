import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({super.key, this.itemBuilder});

  final Widget Function(Feed feed, int index)? itemBuilder;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> with FirebaseHelper {
  bool noFollowings = false;

  @override
  void initState() {
    super.initState();

    UserService.instance.documentChanges.listen((user) {
      if (user == null) return;
      setState(() {
        noFollowings = user.followings.isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (noFollowings) return const Text('You have not followed anyone');

    return FirebaseDatabaseQueryBuilder(
      query: rtdb.ref('feeds').child(FirebaseAuth.instance.currentUser!.uid).orderByChild('createdAt'),
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Something went wrong! ${snapshot.error}');
        }

        return ListView.builder(
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
            return widget.itemBuilder?.call(feed, index) ?? FeedListViewItem(feed: feed);
          },
        );
      },
    );
  }
}
