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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              YouTube(url: post.youtubeId),
              ...post.urls
                  .map((e) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          toast(
                              title: '@todo gallery carousel',
                              message: 'make this photos as carouse widget');
                        },
                        child: CachedNetworkImage(imageUrl: e),
                      ))
                  .toList(),
              Card(
                margin: const EdgeInsets.all(spaceSm),
                child: Padding(
                  padding: const EdgeInsets.all(spaceSm),
                  child: Row(
                    children: [
                      UserDoc(
                          builder: (user) => Column(
                                children: [
                                  UserAvatar(user: user, size: 40),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      user.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withAlpha(240)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                          uid: post.uid),
                      const SizedBox(
                        width: spaceSm,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            PostService.instance.showPostViewDialog(
                                context: context, post: post);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                post.createdAt.toString(),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              const SizedBox(height: spaceXxs),
                              Text(
                                post.content,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
