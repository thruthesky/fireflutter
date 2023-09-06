import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListViewItem extends StatelessWidget {
  const FeedListViewItem({super.key, required this.feed});

  final Feed feed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Post.doc(feed.postId).snapshots(),
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
  }
}
