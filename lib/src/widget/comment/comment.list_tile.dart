import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/service/comment.service.dart';

import 'package:flutter/material.dart';

class CommentListTile extends StatefulWidget {
  const CommentListTile({
    super.key,
    required this.post,
    required this.comment,
  });

  final Post post;
  final Comment comment;

  @override
  State<CommentListTile> createState() => CommentTileState();
}

class CommentTileState extends State<CommentListTile> {
  @override
  Widget build(BuildContext context) {
    // TODO onLongPress
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent(widget.comment.depth)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 6.0),
                child: UserAvatar(
                  uid: widget.comment.uid,
                  key: ValueKey(widget.comment.id),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      UserDisplayName(
                        uid: widget.comment.uid,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17), // TODO customization
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TimestampText(timestamp: widget.comment.createdAt),
                      ),
                    ],
                  ),
                  Text(widget.comment.content),
                  Row(
                    children: [
                      TextButton(
                        child: const Text('Reply'),
                        onPressed: () async {
                          await CommentService.instance.showCommentBottomSheet(
                            context: context,
                            post: widget.post,
                            parent: widget.comment,
                          );
                        },
                      ),
                      TextButton(
                        child: const Text('Like'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
