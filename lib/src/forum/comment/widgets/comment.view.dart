import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentView extends StatefulWidget {
  const CommentView({
    super.key,
    required this.post,
    required this.comment,
    this.onCreate,
  });

  final Post post;
  final Comment comment;
  final Function? onCreate;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  int? previousNoOfLikes;

  Color get lineColor => Theme.of(context).colorScheme.outline.withAlpha(40);
  double lineWidth = 2;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),

      /// Intrinsic height is a natural height from its child
      /// Using VerticalDivider, the VerticalDivider will automatically
      /// takes all the space from the parent
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerticalDivider(
              width: 0,
              thickness: lineWidth,
              color: lineColor,
            ),
            // Horizontal line from the child comment
            Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              height: 16,
              width: widget.comment.leftMargin,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: lineWidth, color: lineColor),
                  left: BorderSide(width: lineWidth, color: lineColor),
                ),

                /// For making a curve to its edge
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                ),
              ),
            ),
            UserAvatar(
              uid: widget.comment.uid,
              onTap: () => UserService.instance.showPublicProfileScreen(
                context: context,
                uid: widget.comment.uid,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserDisplayName(
                        uid: widget.comment.uid,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.comment.createdAt.toShortDate,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  CommentContent(comment: widget.comment),
                  Blocked(
                    otherUserUid: widget.comment.uid,
                    yes: () => SizedBox.fromSize(),
                    no: () => Wrap(
                      spacing: 14,
                      runSpacing: 14,

                      /// Converts to Map<int,string> first to reveal the item's index
                      /// this is for the PhotoViewer so it will immediately open the image
                      /// that the user pressed
                      children: widget.comment.urls
                          .asMap()
                          .map(
                            (index, url) => MapEntry(
                              index,
                              GestureDetector(
                                onTap: () => showGeneralDialog(
                                  context: context,
                                  pageBuilder: (_, __, ___) =>
                                      PhotoViewerScreen(
                                    urls: widget.comment.urls,
                                    selectedIndex: index,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: widget.comment.urls.length == 1
                                        ? 200
                                        : 100,
                                    height: 200,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .values
                          .toList(),
                    ),
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          textStyle: Theme.of(context).textTheme.labelSmall,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -1,
                          ),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final re = await ForumService.instance
                                .showCommentCreateScreen(
                              context: context,
                              post: widget.post,
                              parent: widget.comment,
                            );
                            if (re == true) {
                              widget.onCreate?.call();
                            }
                          },
                          child: Text(T.reply.tr),
                        ),
                        TextButton(
                          onPressed: () =>
                              widget.comment.like(context: context),
                          child: Value(
                            ref: widget.comment.likesRef,
                            builder: (likes) {
                              previousNoOfLikes =
                                  (likes as Map? ?? {}).keys.length;
                              return Text(
                                  '${T.like.tr}${likeText(previousNoOfLikes)}');
                            },
                            onLoading: Text(
                                '${T.like.tr}${likeText(previousNoOfLikes)}'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ChatService.instance.showChatRoomScreen(
                              context: context,
                              otherUid: widget.comment.uid,
                            );
                          },
                          child: Text(T.chat.tr),
                        ),
                        // Prevents the overflow from small devices
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: PopupMenuButton(itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'bookmark',
                                  child: Login(
                                    yes: (uid) => Value(
                                      ref: Bookmark.commentRef(
                                          widget.comment.id),
                                      builder: (v) {
                                        return Text(
                                          v == null
                                              ? T.bookmark.tr
                                              : T.unbookmark.tr,
                                        );
                                      },
                                    ),
                                    no: () => Text(T.bookmark.tr),
                                  ),
                                ),
                                if (widget.comment.uid != myUid)
                                  PopupMenuItem(
                                    value: 'block',
                                    child: Blocked(
                                      otherUserUid: widget.comment.uid,
                                      no: () => Text(T.block.tr),
                                      yes: () => Text(T.unblock.tr),
                                    ),
                                  ),
                                PopupMenuItem(
                                  value: 'report',
                                  child: Text(T.report.tr),
                                ),
                                if (widget.comment.isMine)
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(T.edit.tr),
                                  ),
                                if (widget.comment.isMine)
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(T.delete.tr),
                                  ),
                              ];
                            }, onSelected: (value) async {
                              if (value == 'report') {
                                final re = await input(
                                  context: context,
                                  title: T.reportInputTitle.tr,
                                  subtitle: T.reportInputMessage.tr,
                                  hintText: T.reportInputHint.tr,
                                );
                                if (re == null || re == '') return;
                                await Report.create(
                                  postId: widget.comment.postId,
                                  commentId: widget.comment.id,
                                  reason: re,
                                );
                                if (context.mounted) {
                                  toast(
                                      context: context,
                                      message: T.reportReceived.tr);
                                }
                              } else if (value == 'block') {
                                await UserService.instance.block(
                                  context: context,
                                  otherUserUid: widget.comment.uid,
                                  ask: true,
                                  notify: true,
                                );
                              } else if (value == 'edit') {
                                if (widget.comment.isMine == false) {
                                  return error(
                                    context: context,
                                    message: T.notYourComment.tr,
                                  );
                                }
                                await ForumService.instance
                                    .showCommentUpdateScreen(
                                  context: context,
                                  comment: widget.comment,
                                );
                                widget.post.reload();
                              } else if (value == 'delete') {
                                if (widget.comment.isMine == false) {
                                  return error(
                                    context: context,
                                    message: T.notYourComment.tr,
                                  );
                                }
                                await widget.comment
                                    .delete(context: context, ask: true);
                              } else if (value == 'bookmark') {
                                final re = await Bookmark.toggle(
                                  context: context,
                                  postId: widget.comment.postId,
                                  commentId: widget.comment.id,
                                );
                                if (re != null && context.mounted) {
                                  toast(
                                    context: context,
                                    title: re == true
                                        ? T.bookmark.tr
                                        : T.unbookmark.tr,
                                    message: re == true
                                        ? T.bookmarkMessage.tr
                                        : T.unbookmarkMessage.tr,
                                  );
                                }
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
