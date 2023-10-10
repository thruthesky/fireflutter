import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewContent extends StatelessWidget {
  const PostViewContent({
    super.key,
    required this.post,
    this.contentBackground,
  });

  final Post? post;
  final Color? contentBackground;
  @override
  Widget build(BuildContext context) {
    return post == null
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsets.all(sizeSm),
            color: contentBackground,
            child: post!.content.length < 60
                ? Text(post!.content.replaceAll("\n", " "),
                    style: Theme.of(context).textTheme.bodyMedium)
                : PostContentShowMore(post: post!),
          );
  }
}
