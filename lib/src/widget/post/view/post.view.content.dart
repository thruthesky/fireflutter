import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewContent extends StatelessWidget {
  const PostViewContent({
    super.key,
    required this.post,
  });

  final Post? post;

  @override
  Widget build(BuildContext context) {
    return post == null
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(post!.content),
          );
  }
}
