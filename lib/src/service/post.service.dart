import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/model/category.dart';
import 'package:fireflutter/src/model/post.dart';
import 'package:fireflutter/src/widget/post/create_post_dialog.dart';
import 'package:fireflutter/src/widget/post/post_dialog.dart';
import 'package:flutter/material.dart';

class PostService {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  CollectionReference get postCol => FirebaseFirestore.instance.collection('posts');
  DocumentReference postDoc(String postId) => postCol.doc(postId);

  /// TODO: Support official localization.
  Map<String, String> texts = {};

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
