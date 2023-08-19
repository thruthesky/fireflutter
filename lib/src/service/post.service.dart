import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class PostService with FireFlutter {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  get col => postCol;

  showCreatePostDialog(
    BuildContext context, {
    Category? category,
    required void Function(Post post) success,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CreatePostDialog(
        success: success,
      ),
    );
  }

  createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? files,
  }) {
    // return Post.create(
    //   name: categoryName,
    // );
  }

  /// Shows the Post as a dialog
  showPostDialog(BuildContext context, Post post) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostDialog(
        post: post,
      ),
    );
  }
}
