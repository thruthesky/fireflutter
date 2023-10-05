import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewMeta extends StatelessWidget {
  const PostViewMeta({
    super.key,
    this.post,
    this.headerPadding = const EdgeInsets.fromLTRB(sizeSm, sizeSm, sizeSm, sizeXs),
  });

  final Post? post;
  final EdgeInsetsGeometry headerPadding;

  @override
  Widget build(BuildContext context) {
    return post == null
        ? const SizedBox.shrink()
        : Padding(
            padding: headerPadding,
            child: Row(
              children: [
                UserAvatar(
                  uid: post!.uid,
                  radius: 20,
                  size: 40,
                ),
                const SizedBox(width: sizeXs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserDoc(
                      uid: post!.uid,
                      builder: (user) => Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Row(
                      children: [
                        DateTimeText(
                            dateTime: post!.createdAt,
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11)),
                        DatabaseCount(
                          path: pathSeenBy(post!.id), // 'posts/${post.id}/seenBy',
                          builder: (n) => n < 2
                              ? const SizedBox.shrink()
                              : Text(
                                  " | Views: $n",
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
