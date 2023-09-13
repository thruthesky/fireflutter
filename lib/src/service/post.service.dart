import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostService with FirebaseHelper {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  PostCustomize customize = PostCustomize();

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
      pageBuilder: (context, _, __) =>
          PostEditScreen(categoryId: categoryId, post: post),
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
  showPostViewScreen({
    required BuildContext context,
    Post? post,
    String? postId,
  }) {
    return customize.showPostViewScreen
            ?.call(context, postId: postId, post: post) ??
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) => PostViewScreen(
            post: post,
            postId: postId,
          ),
        );
  }

  /// Shows the posts under a category (or forum)
  showPostListDialog(BuildContext context, String categoryId) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => PostListScreen(
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

  Future<Post> get(String postId) async {
    return await Post.get(postId);
  }

  /// Returns a list of menu widgets on post view screen.
  ///
  ///
  ///
  List<Widget> postViewActions({
    required BuildContext context,
    required Post? post,
  }) {
    if (post == null) return [];
    return [
      PopupMenuButton(
        icon: const Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: "adjust_text_size",
            child: Text("Adjust text size"),
          ),
          if (post.isMine)
            const PopupMenuItem(
              value: "edit",
              child: Text("Edit"),
            ),
          if (post.isMine)
            const PopupMenuItem(
              value: "delete_post",
              child: Text("Delete"),
            ),
          const PopupMenuItem(value: 'report', child: Text('Report')),
          PopupMenuItem(
            value: 'block',
            child: Database(
              path: 'settings/$myUid/blocks/${post.uid}',
              builder: (value) =>
                  Text(value == null ? tr.menu.block : tr.menu.unblock),
            ),
          ),
        ],
        onSelected: (value) async {
          switch (value) {
            case "adjust_text_size":
              // context.push('/adjust_text_size');
              break;
            case "delete_post":
              debugPrint('deleting post');
              break;
            case "edit":
              await PostService.instance.showEditDialog(context, post: post);
              break;

            case 'report':
              if (context.mounted) {
                ReportService.instance.showReportDialog(
                  context: context,
                  postId: post.id,
                  onExists: (id, type) => toast(
                      title: 'Already reported',
                      message: 'You have reported this $type already.'),
                );
              }
              break;
            case 'block':
              final blocked =
                  await toggle('/settings/$myUid/blocks/${post.uid}');
              toast(
                title: blocked ? tr.menu.block : tr.menu.unblock,
                message:
                    blocked ? tr.menu.blockMessage : tr.menu.unblockMessage,
              );
              break;
          }
        },
      ),
    ];
  }
}
