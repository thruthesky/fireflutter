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

  /// Update the post
  ///
  /// [post] is the post to be updated
  ///
  /// [title] is the new title
  ///
  /// [content] is the new content
  @Deprecated("Don't use this. Use Post.update() instead.")
  Future<void> edit({
    required Post post,
    required String title,
    required String content,
    List<String>? urls,
  }) {
    return post.update(
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
  showPostListDialog(BuildContext context, String categoryId) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostListDialog(
        categoryId: categoryId,
      ),
    );
  }

  /// Get multiple posts
  ///
  ///
  Future<List<Post>> gets({
    String? uid,
    String? category,
    int limit = 10,
  }) async {
    Query q = postCol;
    if (uid != null) q = q.where('uid', isEqualTo: uid);
    if (category != null) q = q.where('category', isEqualTo: category);
    q = q.limit(limit);
    q = q.orderBy('createdAt', descending: true);
    final querySnapshot = await q.get();
    if (querySnapshot.size == 0) return [];
    return querySnapshot.docs.map((e) => Post.fromDocumentSnapshot(e)).toList();
  }

  Future<Post> get(String uid) async {
    DocumentSnapshot snapshot = await postDoc(uid).get();
    return Post.fromDocumentSnapshot(snapshot);
  }
}
