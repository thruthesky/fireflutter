import 'package:fireflutter/fireflutter.dart';

import 'package:flutter/material.dart';

class CommentListTile extends StatefulWidget {
  const CommentListTile({
    super.key,
    required this.post,
    required this.comment,
    this.padding,
    this.tileSpacing = 8,
    this.runSpacing = 8,
  });

  final Post post;
  final Comment comment;
  final EdgeInsetsGeometry? padding;
  final double runSpacing;
  final double tileSpacing;

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
      margin: EdgeInsets.only(left: indent(widget.comment.depth), top: widget.tileSpacing),
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
              key: ValueKey(widget.comment.id),
              size: 24,
              radius: 10,
              uid: widget.comment.uid,
              onTap: () => UserService.instance.showPublicProfileScreen(context: context, uid: widget.comment.uid)),
          SizedBox(width: widget.runSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserDoc(
                        uid: widget.comment.uid,
                        builder: (user) => Text(
                              user.name,
                              style: Theme.of(context).textTheme.labelMedium,
                            )),
                    SizedBox(width: widget.runSpacing),
                    DateTimeText(
                      dateTime: widget.comment.createdAt,
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  widget.comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                        await CommentService.instance.showCommentEditBottomSheet(
                          context,
                          comment: widget.comment,
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
