import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostContent extends StatelessWidget {
  const PostContent({
    super.key,
    required this.post,
    this.style,
  });

  final Post post;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment Content
        // TODO tr for 'blocked'
        Text(
          my?.hasBlocked(post.uid) ?? false ? 'blocked' : post.content,
          style: style,
        ),
      ],
    );
  }
}
