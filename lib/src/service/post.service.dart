import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostService with FirebaseHelper {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  get col => postCol;

  @Deprecated('User post.isMine() instead')
  bool isMine(Post post) {
    return UserService.instance.uid == post.uid;
  }

  showCreateDialog(
    BuildContext context, {
    String? categoryId,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostEditDialog(categoryId: categoryId),
    );
  }

  /// Shows the Edit Post as a dialog
  showPostEditDialog(
    BuildContext context, {
    required Post post,
  }) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostEditDialog(post: post),
    );
  }

  Stream<DocumentSnapshot> snapshot({required String postId}) {
    return PostService.instance.col.doc(postId).snapshots();
  }

  @Deprecated('use Post.create')
  Post createPost({
    required String categoryId,
    required String title,
    required String content,
    List<String>? urls,
  }) {
    return Post.create(
      categoryId: categoryId,
      title: title,
      content: content,
      urls: urls,
    );
  }

  Future<void> editPost({
    required Post post,
    required String title,
    required String content,
    List<String>? urls,
  }) {
    return Post.update(
      post: post,
      title: title,
      content: content,
      urls: urls,
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
