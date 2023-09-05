import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({super.key});

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

    return FirebaseDatabaseListView(
      query: rtdb.ref('feeds').child(FirebaseAuth.instance.currentUser!.uid).orderByChild('createdAt'),
      itemBuilder: (context, snapshot) {
        final feed = fromSnapshot(snapshot);
        log('Getting feed');
        return StreamBuilder(
          stream: postDoc(feed.postId).snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final post = Post.fromDocumentSnapshot(snapshot.data!);
              return Card(
                child: Column(
                  children: [
                    YouTube(url: post.youtubeId),
                    ...post.urls.map((e) => CachedNetworkImage(imageUrl: e)).toList(),
                    ListTile(
                      title: Text(post.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserDoc(
                              builder: (user) => Column(
                                    children: [
                                      UserAvatar(user: user, size: 40),
                                      Text(user.name),
                                    ],
                                  ),
                              uid: post.uid),
                          Text(post.content),
                        ],
                      ),
                      onTap: () {
                        PostService.instance.showPostViewDialog(context, post);
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  ({int createdAt, String postId, String uid}) fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map;

    return (
      createdAt: data['createdAt'] as int,
      postId: data['postId'] as String,
      uid: data['uid'] as String,
    );
  }
}
