import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostTitle extends StatelessWidget {
  const PostTitle({
    super.key,
    required this.post,
    this.style,
  });

  final Post post;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      my?.hasBlocked(post.uid) ?? false
          ? tr.blocked
          : post.title.replaceAll("\n", " "),
      style: style,
    );
  }
}
