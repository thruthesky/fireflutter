import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// CommentContent
///
/// Display the content of a post.
class CommentContent extends StatefulWidget {
  const CommentContent({super.key, required this.comment});

  final Comment comment;

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> {
  /// 내용을 캐시해서, 깜빡이지 않도록 한다.
  String content = '';
  @override
  Widget build(BuildContext context) {
    // listen the comment content changes.
    return widget.comment.onFieldChange(
      Field.content,
      initialData: widget.comment.content,
      (v) {
        // if the vlaue of the content is changed and if it's empty, then use the comment's content.
        content = v ?? widget.comment.content;
        return widget.comment.content
                .isNotEmpty // hide bubble when there is no content
            ? _text()
            : const SizedBox.shrink();
      },
      onLoading: _text(),
    );
  }

  _text() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Blocked(
        otherUserUid: widget.comment.uid,
        no: () => LinkifyText(content),
        yes: () => Text(T.blockedContentMessage.tr),
      ),
    );
  }
}
