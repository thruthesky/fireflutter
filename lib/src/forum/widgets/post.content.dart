import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// PostContent
///
/// Display the content of a post.
class PostContent extends StatelessWidget {
  const PostContent({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: post.onFieldChange(
        Field.content,
        (v) => Text(
          v,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
