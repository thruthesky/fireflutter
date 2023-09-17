import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentCustomize {
  Future<Comment> Function(
    BuildContext context, {
    Post? post,
    Comment? parent,
    Comment? comment,
  })? showCommentEditBottomSheet;
  CommentCustomize({
    this.showCommentEditBottomSheet,
  });
}
