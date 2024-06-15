import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Comment view
///
/// Note, to display the comemnt tree, it gets the whole comments of the post and
/// do some computation to display the comment tree. It does not look like a heavy compulation
/// but it needs an attention.
class CommentView extends StatefulWidget {
  const CommentView({
    super.key,
    required this.post,
    required this.comment,
    required this.comments,
    required this.index,
    this.onCreate,
  });

  final Post post;
  final Comment comment;
  final List<Comment> comments;
  final int index;
  final Function? onCreate;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  int? previousNoOfLikes;

  double lineWidth = 2;
  Color get verticalLineColor =>
      // Theme.of(context).colorScheme.outline.withAlpha(40);
      Colors.red;
  bool get isFirstParent =>
      widget.comment.parentId == null && widget.comment.depth == 0;
  bool get isChild => !isFirstParent;
  bool get hasChild => widget.comment.hasChild;
  bool get lastChild => widget.comment.isLastChild;
  bool get parentLastChild => widget.comment.isParentLastChild;
  int get depth => widget.comment.depth;

  List<Comment> parents = [];

  @override
  void initState() {
    super.initState();

    /// Save the accendent comments of the current comment into the [parents] variable
    Comment? parent = widget.comment;
    while (parent != null) {
      parents.add(parent);
      if (parent.parentId == null) break;
      parent = widget.comments.firstWhere(
        (cmt) => cmt.id == parent!.parentId,
      );
    }
    parents = parents.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    /// Intrinsic height is a natural height from its child
    /// Using a combination of [Container] and [Expanded] the line will be automatically drawn
    // padding: EdgeInsets.only(left: widget.comment.leftMargin, right: 16),
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < depth; i++) _newIndentedVerticalLine(i),
            // ...[
            //   SizedBox(width: i == 0 ? 11 : 8),
            //   if (i < depth) ...[
            //     if (parents[i].isParentLastChild == false) ...[
            //       _verticalLine(backgroundColor: Colors.blue),
            //     ],
            //     const SizedBox(width: 8),
            //   ]
            // ],

            /// curved line
            if (isChild) CommentCurvedLine(lineWidth: lineWidth),
            // ...[
            // if (!lastChild) _newIndentedVerticalLine(widget.comment.depth),
            // _verticalLine(),
            //   CommentCurvedLine(lineWidth: lineWidth),
            // ],
            Column(
              children: [
                UserAvatar(
                  uid: widget.comment.uid,
                  onTap: () => UserService.instance.showPublicProfileScreen(
                    context: context,
                    uid: widget.comment.uid,
                  ),
                  size: isFirstParent ? 40 : 24,
                ),

                /// 자식이 있다면, 아바타 아래에 세로 라인을 그린다. 즉, 아바타 아래의 세로 라인은 여기서 그린다.
                if (hasChild) const Expanded(child: VerticalDivider()),
              ],
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
                        // '${widget.comment.parentId}',
                        widget.comment.createdAt.toShortDate,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  CommentContent(comment: widget.comment),
                  Text(
                      'depth: ${widget.comment.depth}, hasChild: ${widget.comment.hasChild}, isLastChild: ${widget.comment.isLastChild}, isParentLastChild: ${widget.comment.isParentLastChild}, hasMoreSibiling: ${widget.comment.hasMoreSibiling}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                      )),
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
                          textStyle:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    fontWeight: FontWeight.w400,
                                  ),
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -1,
                          ),
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(200),
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 세로 라인을 긋는다.
  ///
  /// [depth] 는 코멘트의 깊이를 나타내는 것으로,
  /// 현재 코멘트의 depth 가 3 이라면, 0 부터 1 과 2 총 세번 호출 된다.
  Widget _newIndentedVerticalLine(int depth) {
    print("parents.length: ${parents.length}, depth: $depth");
    // print(
    //     "if (parents[i].hasChild, parent.content: ${parents[i].content} i: $i, ${widget.comment.content}, (${parents[i].hasChild})) return const SizedBox.shrink();");

    // print(
    //     "${widget.comment.content}: if ($i == (${widget.comment.depth} - 1) &&  widget.comment.isLastChild == true) => ${(i == (widget.comment.depth - 1) && widget.comment.isLastChild == true)}");

    // if (parents[i].hasChild) return const SizedBox.shrink();
    return Container(
      width: depth == 0 ? 21 : 30,
      child: Column(
        /// 세로 라인을 오른쪽으로 붙인다. 그래서 커브 라인이 세로 라인에 붙게 한다.
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (maybeDrawVerticalLine(depth))
            Expanded(
              child: VerticalDivider(
                width: 2,
                color: verticalLineColor,
              ),
            ),
        ],
      ),
    );
  }

  /// Return true if the vertical line should be drawn.
  ///
  /// Logic:
  /// 루프 앞 단계의 상위에 sibiling 이 있고, 같은 단계의 다음 형제가 마지막 자식이 아니면,
  ///
  /// 루프 단계는 0 부터 시작.
  /// 나의 단계도 0 부터 시작.
  ///
  /// 공식:
  ///   - 현재 루프 단계에서,
  ///   - 나의 하위에,
  ///   - 현재 루프 + 1 단계에 자식이 있으면 해당 루프 단계에 긋는다.
  ///   - 단, 현재 루프 단계가 나와 같은 depth 이면 긋지 않는다.
  ///
  /// 예)
  ///   - 나의 단계 0. 현재 루프 0. 긋지 않는다. 나의 depth 와 루프 depth 가 동일하기 때문이다.
  ///   - 나의 단계 1. 현재 루프 0. 나의 하위에 0 + 1 = 1 단계 자식이 있으면 0 단계에 긋는다. (단, 나의 depth 와 같으면 긋지 않는다.)
  ///   - 나의 단계 2. 루프 단계 0. 1 단계에 하위 자식이 있어도 나와 depth 가 같으면, 긋지 않는다. 다르면 긋는다.
  ///   - 나의 단계 2. 루프 단계 1. 2 단계에 하위 자식이 있는 1단계에 긋는다.
  ///   - 나의 단계 2. 루프 단계 2. 3 단계에 하위 자식이 있는 2단계에 긋는다.
  ///   - 나의 단계 3. 루프 단계 2. 3 단계에 하위 자식이 있으면, 2 단계에 긋는다.
  bool maybeDrawVerticalLine(int depth) {
    final currComment = widget.comment;
    final parents = Comment.getParents(currComment, widget.comments);
    final depthComment = parents[depth];

    if (currComment.depth == depth) {
      return false;
    }
    for (int i = widget.index + 1; i < widget.comments.length; i++) {
      final target = widget.comments[i];
      if (target.depth == depth + 1 && target.parentId == depthComment.id) {
        return true;
      }
    }
    return false;
  }
}

class CommentCurvedLine extends StatelessWidget {
  const CommentCurvedLine({
    super.key,
    required this.lineWidth,
  });

  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: lineWidth, color: Colors.green),
          left: BorderSide(width: lineWidth, color: Colors.green),
        ),

        /// For making a curve to its edge
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
        ),
      ),
    );
  }
}
