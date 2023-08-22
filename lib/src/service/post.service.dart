import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:flutter/material.dart';

class PostService with FirebaseHelper {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  get col => postCol;

  showCreateDialog(
    BuildContext context, {
    required Category category,
    required void Function(Post post) success,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CreatePostDialog(
        category: category,
        success: success,
      ),
    );
  }

  Future<Post> createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? files,
  }) {
    return Post.create(
      categoryId: categoryId,
      title: title,
      content: content,
      files: files,
    );
  }

  /// Shows the Post as a dialog
  showPostDialog(BuildContext context, Post post) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostDialog(
        post: post,
      ),
    );
  }

  /// Shows the posts under a category (or forum)
  showForumDialog(BuildContext context, Category category) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => ForumDialog(
        category: category,
      ),
    );
  }
}
