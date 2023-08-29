import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/types/last_comment_sort_by_depth.dart';
import 'package:flutter/material.dart';

class CommentEditBottomSheet extends StatefulWidget {
  const CommentEditBottomSheet({
    super.key,
    required this.post,
    this.parent,
    this.labelText,
    this.hintText,
    this.onEdited,
  });

  final Post post;
  final Comment? parent;
  final String? labelText;
  final String? hintText;

  /// This function will be called when the comment is edited including create and update.
  final Function(Comment comment)? onEdited;

  @override
  State<CommentEditBottomSheet> createState() => CommentBoxState();
}

class CommentBoxState extends State<CommentEditBottomSheet> {
  TextEditingController content = TextEditingController();

  String? labelText;
  String? hintText;
  Comment? parentId;
  LastChildCommentSort lastChildCommentSort = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            UserAvatar(
              uid: UserService.instance.uid,
              key: ValueKey(UserService.instance.uid),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: content,
                  minLines: 1,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: labelText ?? 'Comment',
                    hintText: hintText ?? 'Write a comment...',
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () {
                // TODO send photo comment service
              },
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (content.text.isNotEmpty) {
                  final comment = await Comment.create(
                    post: widget.post,
                    parent: widget.parent,
                    content: content.text,
                  );

                  content.text = '';
                  if (widget.onEdited != null) {
                    widget.onEdited!(comment);
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
