import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class CommentList extends StatefulWidget {
  CommentList({
    Key? key,
    required this.post,
    required this.parentId,
    required this.onProfile,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onImageTap,
    required this.onLike,
    this.onDislike,
    this.onChat,
    this.buttonBuilder,
    this.headerBuilder,
    this.contentBuilder,
    this.onBlockUser,
    this.onUnblockUser,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  final PostModel post;
  final String parentId;

  final Function(String uid) onProfile;

  /// Callback on reply button pressed. The parameter is the parent comment of
  /// the new comment to be created.
  ///
  final Function(PostModel post, CommentModel comment) onReply;
  final Function(CommentModel comment) onEdit;
  final Function(CommentModel comment) onReport;
  final Function(CommentModel comment) onDelete;
  final Function(CommentModel comment) onLike;
  final Function(CommentModel comment)? onDislike;
  final Function(int index, List<String> fileList) onImageTap;

  final Function(CommentModel comment)? onChat;

  final Widget Function(String, Function())? buttonBuilder;
  final Widget Function(CommentModel)? headerBuilder;
  final Widget Function(CommentModel)? contentBuilder;

  final Function(String uid)? onBlockUser;
  final Function(String uid)? onUnblockUser;

  final EdgeInsets padding;

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> with ForumMixin {
  List<CommentModel> comments = [];
  StreamSubscription? sub;

  loadComments() {
    sub?.cancel();

    /// It is listening any changes of the docs.
    sub = commentCol
        .where('postId', isEqualTo: widget.post.id)
        .orderBy('createdAt')
        .snapshots()
        .listen((QuerySnapshot snapshots) {
      comments = [];
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        /// is it immediate child?
        final CommentModel c =
            CommentModel.fromJson(snapshot.data() as Json, id: snapshot.id);

        /// if immediate child comment,
        if (c.postId == c.parentId) {
          /// add at bottom
          comments.add(c);
        } else {
          /// It's a comment under another comemnt. Find parent.
          int i = comments.indexWhere((e) => e.id == c.parentId);
          if (i >= 0) {
            c.depth = comments[i].depth + 1;
            comments.insert(i + 1, c);
          }
        }
      });

      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();

    /// When comment is disposed, it means, the post and all of its comments
    /// scrolled out of visible area. So, close the post for better scrolling
    /// experience. Or scroll will not be smooth.
    widget.post.open = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.padding,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: comments.length,
      itemBuilder: (ctx, i) {
        final CommentModel comment = comments[i];

        return Container(
          key: ValueKey(comment.id),
          margin: EdgeInsets.only(left: comment.depth * 16, bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text('Comment Id: ${comment.id}'),
              _commentHeader(comment),
              _contentBuilder(comment),
              ForumPoint(
                uid: comment.uid,
                point: comment.point,
                padding: EdgeInsets.only(top: 8.0, left: 8.0),
              ),
              ImageList(
                files: comment.files,
                onImageTap: (i) => widget.onImageTap(i, comment.files),
              ),
              if (comment.deleted == false)
                ButtonBase(
                  uid: comment.uid,
                  isPost: false,
                  onProfile: widget.onProfile,
                  onReply: () => widget.onReply(widget.post, comment),
                  onReport: () => widget.onReport(comment),
                  onEdit: () => widget.onEdit(comment),
                  onDelete: () => widget.onDelete(comment),
                  onLike: () => widget.onLike(comment),
                  onDislike: () => widget.onDislike == null
                      ? null
                      : widget.onDislike!(comment),
                  buttonBuilder: widget.buttonBuilder,
                  likeCount: comment.like,
                  dislikeCount: comment.dislike,
                  onChat: (widget.onChat != null)
                      ? () => widget.onChat!(comment)
                      : null,
                  onBlockUser: widget.onBlockUser,
                  onUnblockUser: widget.onUnblockUser,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _commentHeader(CommentModel comment) {
    if (widget.headerBuilder != null) return widget.headerBuilder!(comment);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: UserDoc(
        uid: comment.uid,
        builder: (user) => Row(
          children: [
            UserProfilePhoto(uid: user.uid),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName.isNotEmpty
                    ? "${user.displayName}"
                    : "No name"),
                SizedBox(height: 8),
                ShortDate(comment.createdAt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contentBuilder(CommentModel comment) {
    return widget.contentBuilder != null
        ? widget.contentBuilder!(comment)
        : Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.secondary.withAlpha(150),
            child: Text("${comment.displayContent}"),
          );
  }
}
