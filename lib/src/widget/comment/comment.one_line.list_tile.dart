import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/widget/common/display_uploaded_files.dart';
import 'package:flutter/material.dart';

/// A widget that display comment in one line.
///
///
class CommentOneLineListTile extends StatefulWidget {
  const CommentOneLineListTile({
    super.key,
    required this.post,
    required this.comment,
    this.padding,
    this.contentPadding,
    this.contentMargin,
    this.contentBorderRadius,
    this.runSpacing = 8,
    this.onTapContent,
    this.fixedDepth,
    this.hideActionButton = false,
    this.hideLikeButton = false,
  });

  final Post post;
  final Comment comment;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? contentMargin;
  final BorderRadiusGeometry? contentBorderRadius;
  final double runSpacing;

  /// Fixed depth of the comment. If null, the depth of the comment will be used.
  final int? fixedDepth;

  /// Option to hide action button
  final bool hideActionButton;

  /// Option to hide like button
  final bool hideLikeButton;

  /// Callback function for content tap
  final void Function()? onTapContent;

  @override
  State<CommentOneLineListTile> createState() => _CommentOneLineListTileState();
}

class _CommentOneLineListTileState extends State<CommentOneLineListTile> {
  bool? iLiked;

  bool get notBlocked => my != null && my!.hasBlocked(widget.comment.uid) == false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent(widget.fixedDepth ?? widget.comment.depth)),
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.comment.deleted) ...[
            Flexible(
              child: Text(widget.comment.deletedReason ?? 'The comment was deleted by the user.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium!),
            ),
          ] else ...[
            const SizedBox(
              width: sizeXs + 5,
            ),
            UserAvatar(
              uid: widget.comment.uid,
              radius: 10,
              size: 24,
              onTap: () => UserService.instance.showPublicProfileScreen(
                context: context,
                uid: widget.comment.uid,
              ),
            ),
            SizedBox(width: widget.runSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: UserDisplayName(
                          uid: widget.comment.uid,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      SizedBox(width: widget.runSpacing),
                      DateTimeText(
                        dateTime: widget.comment.createdAt,
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 11),
                      ),
                    ],
                  ),

                  // photos of the comment
                  DisplayUploadedFiles(otherUid: widget.comment.uid, urls: widget.comment.urls),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTapContent,
                    child: Container(
                      margin: widget.contentMargin ?? const EdgeInsets.all(0),
                      padding: widget.contentPadding ?? const EdgeInsets.all(0),
                      width: double.infinity,
                      child: CommentContent(
                        comment: widget.comment,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                  ),

                  // comment buttons
                  if (notBlocked)
                    Row(
                      children: [
                        // no of likes
                        DatabaseCount(
                          path: pathCommentLikedBy(widget.comment.id, all: true),
                          builder: (n) => n == 0
                              ? const SizedBox.shrink()
                              : TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 0, right: 8),
                                    minimumSize: Size.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: () async => UserService.instance.showLikedByListScreen(
                                    context: context,
                                    uids: await getKeys(pathCommentLikedBy(widget.comment.id, all: true)),
                                  ),
                                  child: Text(
                                    n == 0
                                        ? tr.like
                                        : tr.noOfLikes.replaceAll(
                                            '#no',
                                            n.toString(),
                                          ),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                        ),
                        if (widget.hideActionButton == false) ...[
                          // reply
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 0, right: 8),
                              minimumSize: Size.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              if (my?.isDisabled ?? false) {
                                toast(title: tr.disabled, message: tr.disabledMessage);
                                return;
                              }
                              CommentService.instance.showCommentEditBottomSheet(
                                context,
                                post: widget.post,
                                parent: widget.comment,
                              );
                            },
                            child: Text(
                              tr.reply,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    // The color of the post card is actually
                                    // comming from colorScheme.secondary
                                    // However, it has .withAlpha(20) which make the
                                    // actual color nearly like the background color.
                                    // So, we need to use onBackground color here.
                                    //
                                    // Please review if we have to change it
                                    color: Theme.of(context).colorScheme.onBackground,
                                    // color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          Flexible(
                            child: PopupMenuButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                size: 16,
                              ),
                              itemBuilder: (context) {
                                return [
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Text('Report'),
                                  ),
                                  if (widget.comment.uid == myUid)
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                  if (widget.comment.uid == myUid)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    )
                                ];
                              },
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await CommentService.instance
                                      .showCommentEditBottomSheet(context, comment: widget.comment);
                                }
                                if (value == 'report') {
                                  if (context.mounted) {
                                    ReportService.instance.showReportDialog(
                                      context: context,
                                      commentId: widget.comment.id,
                                      onExists: (id, type) => toast(
                                          title: 'Already reported', message: 'You have reported this $type already.'),
                                    );
                                  }
                                }

                                //need delete function
                                if (value == 'delete') {
                                  if (!mounted) return;
                                  final re = await confirm(
                                      context: context,
                                      title: 'Delete Comment',
                                      message: 'Are you sure on deleting this comment?');
                                  if (re == true) {
                                    await widget.comment.delete();
                                    toast(title: 'Comment deleted', message: 'Comment deleted successfully.');
                                  }
                                }
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                ],
              ),
            ),
            if (notBlocked && widget.hideLikeButton == false)
              Database(
                path: pathCommentLikedBy(widget.comment.id),
                builder: (value, path) {
                  iLiked = value == null;
                  return likeButton();
                },
                onWaiting: iLiked == null ? const SizedBox.shrink() : likeButton(),
              ),
          ]
        ],
      ),
    );
  }

  Widget likeButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () => widget.comment.like(),
      icon: Icon(
        iLiked! ? Icons.favorite_border : Icons.favorite,
        size: 16,
        // Used tertiary color here
        // originally the color uses colorScheme.error which is kinda
        // confusing and the name is not helpful in the color.
        color: iLiked! ? null : Theme.of(context).colorScheme.tertiary.tone(50).saturation(isDark ? 60 : 50),
      ),
    );
  }
}
