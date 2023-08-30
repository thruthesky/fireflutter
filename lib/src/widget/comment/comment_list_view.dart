import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CommentListView extends StatefulWidget {
  const CommentListView({
    super.key,
    this.itemBuilder,
    this.emptyBuilder,
    this.pageSize = 10,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
    required this.post,
    this.replyingTo,
    this.onShowReplyBox,
    this.onCommentDisplay,
  });

  final int pageSize;
  final Widget Function(BuildContext, Comment)? itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;

  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  final Post post;

  final String? replyingTo;
  final Function(Comment comment)? onShowReplyBox;
  final Function(Comment comment)? onCommentDisplay;

  @override
  State<CommentListView> createState() => CommentListViewState();
}

class CommentListViewState extends State<CommentListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FirestoreListView(
          // todo indentation
          query: CommentService.instance.commentCol.where("postId", isEqualTo: widget.post.id).orderBy("sort"),
          itemBuilder: (context, QueryDocumentSnapshot snapshot) {
            final comment = Comment.fromDocumentSnapshot(snapshot);
            widget.onCommentDisplay?.call(comment);
            // Will we have a problem in comments if this paginates?
            // Since the last comment may not show yet upon loading the screen.
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, comment);
            } else {
              return CommentListTile(
                post: widget.post,
                comment: comment,
              );
            }
          },
          emptyBuilder: (context) {
            if (widget.emptyBuilder != null) {
              return widget.emptyBuilder!(context);
            } else {
              if (widget.replyingTo != null) return Center(child: Text(tr.comment.noReply));
              return Center(child: Text(tr.comment.noComment));
            }
          },
          errorBuilder: (context, error, stackTrace) {
            log(error.toString(), stackTrace: stackTrace);
            return Center(child: Text('Error loading posts $error'));
          },
          pageSize: widget.pageSize,
          controller: widget.scrollController,
          primary: widget.primary,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.padding,
          dragStartBehavior: widget.dragStartBehavior,
          keyboardDismissBehavior: widget.keyboardDismissBehavior,
          clipBehavior: widget.clipBehavior,
        ),
      ],
    );
  }
}
