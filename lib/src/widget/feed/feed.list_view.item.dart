import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FeedListViewItem extends StatelessWidget {
  const FeedListViewItem({
    super.key,
    required this.feed,
    this.avatarBuilder,
    this.textBuilder,
    this.onTap,
  });

  final Feed feed;
  final Widget Function(BuildContext, Post)? avatarBuilder;
  final Widget Function(BuildContext, Post)? textBuilder;
  final Function(Post)? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Post.doc(feed.postId).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final post = Post.fromDocumentSnapshot(snapshot.data!);
          return GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap?.call(post);
              } else {
                PostService.instance
                    .showPostViewScreen(context: context, post: post);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                YouTubeThumbnail(youtubeId: post.youtubeId),
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
                  margin: const EdgeInsets.all(sizeSm),
                  child: Padding(
                    padding: const EdgeInsets.all(sizeSm),
                    child: Row(
                      children: [
                        _avatarBuilder(context, post),
                        const SizedBox(
                          width: sizeSm,
                        ),
                        Expanded(
                          child: _textBuilder(context, post),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _avatarBuilder(BuildContext context, Post post) {
    return avatarBuilder?.call(context, post) ??
        UserDoc(
            builder: (user) => Column(
                  children: [
                    UserAvatar(user: user, size: 40),
                    SizedBox(
                      width: 40,
                      child: Text(
                        user.name,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
            uid: post.uid);
  }

  Widget _textBuilder(BuildContext context, Post post) {
    if (textBuilder != null) return textBuilder!(context, post);
    return Column(
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
        const SizedBox(height: sizeXxs),
        Text(
          post.content,
        ),
      ],
    );
  }
}
