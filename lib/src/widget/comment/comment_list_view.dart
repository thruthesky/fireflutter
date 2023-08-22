import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:fireflutter/src/service/comment.service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CommentListView extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return FirestoreListView(
      query: CommentService.instance.commentCol.where("postId", isEqualTo: post.id).orderBy("createdAt"),
      itemBuilder: (context, QueryDocumentSnapshot snapshot) {
        final comment = Comment.fromDocumentSnapshot(snapshot);
        if (itemBuilder != null) {
          return itemBuilder!(context, comment);
        } else {
          return CommentTile(comment: comment);
        }
      },
      emptyBuilder: (context) {
        if (emptyBuilder != null) {
          return emptyBuilder!(context);
        } else {
          return Center(child: Text(tr.comment.noPost));
        }
      },
      errorBuilder: (context, error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return Center(child: Text('Error loading posts $error'));
      },
      pageSize: pageSize,
      controller: scrollController,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      clipBehavior: clipBehavior,
    );
  }
}
