import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentCustomize {
  Future<Comment> Function(
    BuildContext context, {
    Post? post,
    Comment? parent,
    Comment? comment,
  })? showCommentEditBottomSheet;

  Future<void> Function(BuildContext context, Post post)?
      showCommentListBottomSheet;

  CommentCustomize({
    this.showCommentEditBottomSheet,
    this.showCommentListBottomSheet,
  });
}
