import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

/// CommentContent
///
/// Display the content of a post.
class CommentContent extends StatefulWidget {
  const CommentContent({super.key, required this.comment});

  final CommentModel comment;

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> {
  /// 내용을 캐시해서, 깜빡이지 않도록 한다.
  String content = '';
  @override
  Widget build(BuildContext context) {
    return widget.comment.onFieldChange(
      Field.content,
      (v) {
        content = v ?? '';
        return _text();
      },
      onLoading: _text(),
    );
  }

  _text() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
