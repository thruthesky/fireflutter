import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostCustomize {
  Future Function(BuildContext context, {String? postId, Post? post})?
      showPostViewScreen;
  Future<Post?> Function(BuildContext context,
      {String? categoryId, Post? post})? showEditScreen;
  Widget Function(Post? post)? postViewButtonBuilder;
  Widget Function(Post post)? shareButtonBuilder;

  PostCustomize({
    this.showEditScreen,
    this.showPostViewScreen,
    this.postViewButtonBuilder,
    this.shareButtonBuilder,
  });
}
