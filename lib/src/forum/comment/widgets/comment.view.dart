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
  State<CommentView> createState() => _CommnetViewState();
}

class _CommnetViewState extends State<CommentView> {
  int? previousNoOfLikes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: widget.comment.leftMargin),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              CommentContent(comment: widget.comment),
              const SizedBox(height: 8),
              Blocked(
                otherUserUid: widget.comment.uid,
                yes: () => SizedBox.fromSize(),
                no: () => DisplayDatabasePhotos(
                  urls: widget.comment.urls,
                  ref: widget.comment.urlsRef,
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final re =
                            await ForumService.instance.showCommentCreateScreen(
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
                      onPressed: () => widget.comment.like(context: context),
                      child: Value(
                        ref: widget.comment.likesRef,
                        builder: (likes) {
                          previousNoOfLikes = (likes as Map? ?? {}).keys.length;
                          return Text(
                              '${T.like.tr}${likeText(previousNoOfLikes)}');
                        },
                        onLoading:
                            Text('${T.like.tr}${likeText(previousNoOfLikes)}'),
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
                    const Spacer(),
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'bookmark',
                          child: Login(
                            yes: (uid) => Value(
                              ref: Bookmark.commentRef(widget.comment.id),
                              builder: (v) {
                                return Text(
                                  v == null ? T.bookmark.tr : T.unbookmark.tr,
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
                              no: () =>  Text(T.block.tr),
                              yes: () =>  Text(T.unblock.tr),
                            ),
                          ),
                         PopupMenuItem(
                          value: 'report',
                          child: Text(T.report.tr),
                        ),
                         PopupMenuItem(
                          value: 'edit',
                          child: Text(T.edit.tr),
                        ),
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
                          toast(context: context, message: T.reportReceived.tr);
                        }
                      } else if (value == 'block') {
                        await UserService.instance.block(
                          context: context,
                          otherUserUid: widget.comment.uid,
                          ask: true,
                          notify: true,
                        );
                      } else if (value == 'edit') {
                        await ForumService.instance.showCommentUpdateScreen(
                          context: context,
                          comment: widget.comment,
                        );
                        widget.post.reload();
                      } else if (value == 'delete') {
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
                            title: re == true ? T.bookmark.tr : T.unbookmark.tr,
                            message: re == true
                                ? T.bookmarkMessage.tr
                                : T.unbookmarkMessage.tr,
                          );
                        }
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
