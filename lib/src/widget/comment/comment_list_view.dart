import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CommentListViewController extends ChangeNotifier {
  CommentListViewState? state;

  hideAllReplyBox() {
    // TODO hide all reply box
  }
}

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
    required this.postId,
    this.replyingTo,
    this.label,
    this.onShowReplyBox,
    this.controller,
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
  final String postId;

  final CommentListViewController? controller;

  final String? replyingTo;
  final String? label;
  final Function()? onShowReplyBox;

  @override
  State<CommentListView> createState() => CommentListViewState();
}

class CommentListViewState extends State<CommentListView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Text(
              widget.label ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        FirestoreListView(
          query: widget.replyingTo == null
              ? CommentService.instance.commentCol.where("postId", isEqualTo: widget.postId).orderBy("createdAt")
              : CommentService.instance.commentCol.where("replyTo", isEqualTo: widget.replyingTo).orderBy("createdAt"),
          itemBuilder: (context, QueryDocumentSnapshot snapshot) {
            final comment = Comment.fromDocumentSnapshot(snapshot);
            if (widget.replyingTo == null && comment.replyTo != null) return const SizedBox.shrink();
            if (widget.itemBuilder != null) {
              return widget.itemBuilder!(context, comment);
            } else {
              return CommentTile(
                comment: comment,
                onShowReplyBox: () {
                  widget.onShowReplyBox?.call();
                },
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
