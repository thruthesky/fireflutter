import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/types/last_comment_sort_by_depth.dart';
import 'package:flutter/material.dart';

class CommentEditBottomSheet extends StatefulWidget {
  const CommentEditBottomSheet({
    super.key,
    this.post,
    this.parent,
    this.comment,
    this.labelText,
    this.hintText,
    this.onEdited,
  });

  final Post? post;
  final Comment? parent;
  final Comment? comment;
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

  bool get isCreate => widget.post != null;
  bool get isUpdate => !isCreate;

  @override
  void initState() {
    super.initState();
    if (widget.comment != null) {
      content.text = widget.comment!.content;
    }
  }

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
                  minLines: 2,
                  maxLines: 5,
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
                if (content.text.isEmpty) {
                  return warningSnackbar(context, 'Please input a comment.');
                }

                Comment comment;
                if (isCreate) {
                  comment = await Comment.create(
                    post: widget.post!,
                    parent: widget.parent,
                    content: content.text,
                  );
                } else {
                  comment = await widget.comment!.update(
                    content: content.text,
                  );
                }
                content.text = '';
                if (widget.onEdited != null) {
                  widget.onEdited!(comment);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
