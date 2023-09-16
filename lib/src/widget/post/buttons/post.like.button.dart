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
  final Widget Function(Post post) builder;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return PostDoc(
      postId: post.id,
      post: post,
      builder: (post) => InkWell(
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: builder(post),
        ),
        onTap: () => post.like(),
      ),
    );
  }
}
