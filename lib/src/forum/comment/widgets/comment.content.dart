import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// CommentContent
///
/// Display the content of a post.
class CommentContent extends StatefulWidget {
  const CommentContent({
    super.key,
    required this.comment,
    this.padding,
  });

  final Comment comment;
  final EdgeInsets? padding;

  @override
  State<CommentContent> createState() => _CommentContentState();
}

class _CommentContentState extends State<CommentContent> {
  /// 내용을 캐시해서, 깜빡이지 않도록 한다.
  String content = '';

  @override
  Widget build(BuildContext context) {
    /// Adds a padding inside the CommentContent
    /// instead of using [SizedBox] outside of this widget
    /// because there will be a big space and ruins the spacing
    /// when the content is null
    return Padding(
      padding: widget.padding ??
          EdgeInsets.only(
            top: widget.comment.content.isNotEmpty ? 8 : 0,
            bottom: widget.comment.urls.isNotEmpty ? 12 : 0,
          ),
      // listen the comment content changes.
      child: widget.comment.onFieldChange(
        Field.content,
        initialData: widget.comment.content,
        (v) {
          // if the vlaue of the content is changed and if it's empty, then use the comment's content.
          content = v ?? widget.comment.content;
          return widget.comment.content
                  .isNotEmpty // hide bubble when there is no content
              ? text()
              : const SizedBox.shrink();
        },
        onLoading: text(),
      ),
    );
  }

  text() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Blocked(
        otherUserUid: widget.comment.uid,
        no: () => LinkifyText(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        yes: () => Text(T.blockedContentMessage.tr),
      ),
    );
  }
}
