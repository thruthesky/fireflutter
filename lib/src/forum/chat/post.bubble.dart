import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostBubble extends StatelessWidget {
  const PostBubble({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Text(post.content),
    );
  }
}
