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
    if (widget.comment.deleted == true) {
      return Container(
        margin: const EdgeInsets.only(
          left: sizeSm,
          right: sizeSm,
          top: sizeXs,
          bottom: sizeSm,
        ),
        padding: EdgeInsets.only(
          left: indent(widget.comment.depth),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.secondary.withAlpha(100),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.comment.deletedReason}', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(
        left: sizeSm,
        right: sizeSm,
        top: sizeXs,
        bottom: sizeSm,
      ),
      padding: EdgeInsets.only(
        left: indent(widget.comment.depth),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserAvatar(
                  key: ValueKey(widget.comment.id),
                  size: 40,
                  radius: 20,
                  uid: widget.comment.uid,
                  onTap: () => UserService.instance.showPublicProfileScreen(context: context, uid: widget.comment.uid)),
              const SizedBox(width: 8),
              UserDisplayName(
                uid: widget.comment.uid,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const Spacer(),
              DateTimeText(dateTime: widget.comment.createdAt),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: sizeXxl),
            child: Text(
              widget.comment.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
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
          const LoginFirst(),
          Row(
            children: [
              TextButton(
                child: const Text('Reply'),
                onPressed: () async {
                  await CommentService.instance
                      .showCommentEditBottomSheet(context, post: widget.post, parent: widget.comment);
                },
              ),
              CommentDoc(
                comment: widget.comment,
                builder: (comment) {
                  return TextButton(
                    child: Text('Like ${comment.noOfLikes}'),
                    onPressed: () {
                      comment.like();
                    },
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  ReportService.instance.showReportDialog(
                    context: context,
                    commentId: widget.comment.id,
                    onExists: (id, type) =>
                        toast(title: 'Already reported', message: 'You have reported this $type already.'),
                  );
                },
                child: const Text('Report'),
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
    );
  }
}
