import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostLikeButton extends StatelessWidget {
  const PostLikeButton({
    super.key,
    required this.post,
    required this.builder,
    this.padding,
  });

  final Post post;
  final Widget Function(int n) builder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Database(
      path: pathPostLikedBy(post.id, all: true),
      builder: (v, p) => builder(v),

      //  n == 0
      //     ? const SizedBox.shrink()
      //     : Text(
      //         " view: $n",
      //         style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
      //       ),
    );
  }
}
