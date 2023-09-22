import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostService {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  PostCustomize customize = PostCustomize();

  get col => postCol;

  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;

  bool enableSeenBy = false;

  /// Callback functions on post create and update. Note that, we don't support
  /// post delete.
  Function(Post)? onCreate;
  Function(Post)? onUpdate;

  init({
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
    bool enableSeenBy = false,
    void Function(Post)? onCreate,
    void Function(Post)? onUpdate,
    PostCustomize? customize,
  }) {
    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;
    this.uploadFromFile = uploadFromFile;

    this.enableSeenBy = enableSeenBy;

    this.onCreate = onCreate;
    this.onUpdate = onUpdate;

    if (customize != null) {
      this.customize = customize;
    }
  }

  /// Shows the Edit Post as a dialog
  Future<Post?> showEditScreen(
    BuildContext context, {
    String? categoryId,
    Post? post,
  }) {
    return customize.showEditScreen?.call(context, categoryId: categoryId, post: post) ??
        showGeneralDialog<Post?>(
          context: context,
          pageBuilder: (context, _, __) => PostEditScreen(categoryId: categoryId, post: post),
        );
  }

  Stream<DocumentSnapshot> snapshot({required String postId}) {
    return PostService.instance.col.doc(postId).snapshots();
  }

  /// Shows the Post view as a dialog
  showPostViewScreen({
    required BuildContext context,
    Post? post,
    String? postId,
  }) {
    return customize.showPostViewScreen?.call(context, postId: postId, post: post) ??
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) => PostViewScreen(
            post: post,
            postId: postId,
          ),
        );
  }

  /// Shows the posts under a category (or forum)
  showPostListScreen(BuildContext context, String categoryId) {
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
          if (loggedIn)
            PopupMenuItem(
              value: 'block',
              child: Database(
                path: pathBlock(post.uid),
                builder: (value, p) => Text(value == null ? tr.block : tr.unblock),
              ),
            ),
          if (UserService.instance.isAdmin)
            const PopupMenuItem(
              value: "copyId",
              child: Text("Copy Id to clipboard"),
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
              await PostService.instance.showEditScreen(context, post: post);
              break;

            case 'report':
              if (context.mounted) {
                ReportService.instance.showReportDialog(
                  context: context,
                  postId: post.id,
                  onExists: (id, type) =>
                      toast(title: 'Already reported', message: 'You have reported this $type already.'),
                );
              }
              break;
            case 'block':
              final blocked = await toggle(pathBlock(post.uid));
              toast(
                title: blocked ? tr.block : tr.unblock,
                message: blocked ? tr.blockMessage : tr.unblockMessage,
              );
              break;
            case 'copyId':
              await Clipboard.setData(ClipboardData(text: post.id));
              toast(title: 'Copy to clipboard', message: "${post.id} was copy to clipboard");
          }
        },
      ),
    ];
  }
}
