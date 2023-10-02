import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentCustomize {
  Future<Comment?> Function(
    BuildContext context, {
    Comment? comment,
    required Future<Comment?> Function() next,
    Comment? parent,
    Post? post,
  })? showCommentEditBottomSheet;

  Future<void> Function(BuildContext context, Post post)? showCommentListBottomSheet;

  CommentCustomize({
    this.showCommentEditBottomSheet,
    this.showCommentListBottomSheet,
  });
}
