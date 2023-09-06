import 'package:fireflutter/fireflutter.dart';

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
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: EdgeInsets.only(left: indent(widget.comment.depth)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            uid: widget.comment.uid,
            key: ValueKey(widget.comment.id),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: UserDisplayName(
                        uid: widget.comment.uid,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: DateTimeText(dateTime: widget.comment.createdAt),
                    ),
                  ],
                ),
                Text(widget.comment.content),
                widget.comment.urls.isNotEmpty
                    ? Column(
                        children: widget.comment.urls
                            .map((e) => Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 4, 10, 0),
                                  child: DisplayMedia(url: e),
                                ))
                            .toList(),
                      )
                    : const SizedBox.shrink(),
                Row(
                  children: [
                    TextButton(
                      child: const Text('Reply'),
                      onPressed: () async {
                        await CommentService.instance.showCommentEditBottomSheet(
                          context,
                          post: widget.post,
                          parent: widget.comment,
                        );
                      },
                    ),
                    CommentDoc(
                      comment: widget.comment,
                      builder: (comment) {
                        return TextButton(
                          child: Text('Like ${comment.noOfLikes}'),
                          onPressed: () {
                            comment.likeOrUnlike();
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        await CommentService.instance.showCommentEditBottomSheet(context, comment: widget.comment);
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
