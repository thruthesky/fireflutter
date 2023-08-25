import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostService with FirebaseHelper {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  get col => postCol;

  bool isMine(Post post) {
    return UserService.instance.uid == post.uid;
  }

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

  Stream<DocumentSnapshot> snapshot({required String postId}) {
    return PostService.instance.col.doc(postId).snapshots();
  }

  Post createPost({
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

  Future<void> editPost({
    required String postId,
    required String title,
    required String content,
    List<String>? files,
  }) {
    return Post.update(
      postId: postId,
      title: title,
      content: content,
      files: files,
    );
  }

  /// Shows the Post view as a dialog
  showPostViewDialog(BuildContext context, Post post) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostViewDialog(
        post: post,
      ),
    );
  }

  /// Shows the Edit Post as a dialog
  showPostEditDialog(BuildContext context, Post post) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => EditPostDialog(
        post: post,
      ),
    );
  }

  /// Shows the posts under a category (or forum)
  showPostListDialog(BuildContext context, Category category) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostListDialog(
        categoryId: category.id,
      ),
    );
  }
}
