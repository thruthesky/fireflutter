import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostService with FirebaseHelper {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  get col => postCol;

  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;

  init({
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
  }) {
    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;
    this.uploadFromFile = uploadFromFile;
  }

  /// Shows the Edit Post as a dialog
  Future<Post?> showEditDialog(
    BuildContext context, {
    String? categoryId,
    Post? post,
  }) {
    return showGeneralDialog<Post?>(
      context: context,
      pageBuilder: (context, _, __) => PostEditDialog(categoryId: categoryId, post: post),
    );
  }

  Stream<DocumentSnapshot> snapshot({required String postId}) {
    return PostService.instance.col.doc(postId).snapshots();
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
