import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentContent extends StatelessWidget {
  const CommentContent({
    super.key,
    required this.comment,
    this.style,
  });

  final Comment comment;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comment.deleted)
          Text(
            comment.deletedReason ?? 'This comment has beed deleted.',
            style: style != null
                ? style?.copyWith(fontStyle: FontStyle.italic)
                : const TextStyle(fontStyle: FontStyle.italic),
          )
        else
          Text(
            key: const Key('CommentContent'),
            my?.hasBlocked(comment.uid) ?? false ? tr.blocked : comment.content,
            style: style,
          ),
      ],
    );
  }
}
