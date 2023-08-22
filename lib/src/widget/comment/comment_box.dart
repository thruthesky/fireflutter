import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/material.dart';

class CommentBox extends StatefulWidget {
  const CommentBox({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  TextEditingController content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
            children: [
              UserAvatar(
                uid: widget.post.uid,
                key: ValueKey(widget.post.uid),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    controller: content,
                    minLines: 1,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Comment',
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Row(
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
                    CommentService.instance.createComment(postId: widget.post.id, content: content.text);
                    content.text = '';
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
