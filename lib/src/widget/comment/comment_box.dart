import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/material.dart';

class CommentBox extends StatefulWidget {
  const CommentBox({
    super.key,
    required this.postId,
    this.replyTo,
    this.labelText,
    this.hintText,
    this.onSubmit,
  });

  final String postId;
  final String? replyTo;
  final String? labelText;
  final String? hintText;
  final Function()? onSubmit;

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  TextEditingController content = TextEditingController();

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
                child: TextFormField(
                  autofocus: true,
                  controller: content,
                  minLines: 1,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.labelText ?? 'Comment',
                    hintText: widget.hintText ?? 'Write a comment...',
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
              onPressed: () {
                if (content.text.isNotEmpty) {
                  // TODO send comment service
                  CommentService.instance
                      .createComment(postId: widget.postId, content: content.text, replyTo: widget.replyTo);
                  // TODO show the comment blink, scroll to the comment
                  content.text = '';
                  widget.onSubmit?.call();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
