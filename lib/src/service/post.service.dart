import 'package:cached_network_image/cached_network_image.dart';
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

  // Updated from this.
  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;
  // bool uploadPhotoVideoFromGallery = false;
  // bool uploadPhotoFromCamera = false;
  // bool uploadPhotoFromGallery = false;
  // bool uploadVideoFromCamera = false;
  // bool uploadVideoFromGallery = false;
  // bool uploadFromFile = false;

  bool enableSeenBy = false;

  /// Callback functions on post create and update. Note that, we don't support
  /// post delete.
  void Function(Post)? onCreate;
  void Function(Post)? onUpdate;

  /// [onLike] is called when a post is liked or unliked by the login user.
  void Function(Post post, bool isLiked)? onLike;

  // Enable/Disable push notification when post is liked
  bool enableNotificationOnLike = false;

  init({
    // Updated from this.
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
    // bool uploadPhotoVideoFromGallery = false,
    // bool uploadPhotoFromCamera = false,
    // bool uploadPhotoFromGallery = true,
    // bool uploadVideoFromCamera = true,
    // bool uploadVideoFromGallery = false,
    // bool uploadFromFile = true,
    bool enableSeenBy = false,
    void Function(Post)? onCreate,
    void Function(Post)? onUpdate,
    void Function(Post post, bool isLiked)? onLike,
    PostCustomize? customize,
    bool enableNotificationOnLike = false,
  }) {
    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;

    // TODO clean up

    // this.uploadPhotoVideoFromGallery = uploadPhotoVideoFromGallery;
    // this.uploadPhotoFromCamera = uploadPhotoFromCamera;
    // this.uploadPhotoFromGallery = uploadPhotoFromGallery;
    // this.uploadVideoFromCamera = uploadVideoFromCamera;
    // this.uploadVideoFromGallery = uploadVideoFromGallery;
    this.uploadFromFile = uploadFromFile;

    this.enableSeenBy = enableSeenBy;

    this.onCreate = onCreate;
    this.onUpdate = onUpdate;
    this.onLike = onLike;

    this.enableNotificationOnLike = enableNotificationOnLike;

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
    Function(BuildContext, Post)? onPressBackButton,
  }) {
    return customize.showPostViewScreen?.call(context, postId: postId, post: post) ??
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) => PostViewScreen(
            post: post,
            postId: postId,
            onPressBackButton: onPressBackButton,
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
  /// [limit] is the number of posts to get. If [limit] is 0, it will get all posts.
  Future<List<Post>> gets({
    String? uid,
    String? category,
    int limit = 10,
  }) async {
    Query q = postCol;
    if (uid != null) q = q.where('uid', isEqualTo: uid);
    if (category != null) q = q.where('category', isEqualTo: category);
    if (limit > 0) {
      q = q.limit(limit);
    }
    q = q.orderBy('createdAt', descending: true);
    final querySnapshot = await q.get();
    if (querySnapshot.size == 0) return [];
    return querySnapshot.docs.map((e) => Post.fromDocumentSnapshot(e)).toList();
  }

  Future<Post> get(String postId) async {
    return await Post.get(postId);
  }

  // Reutrns a list of Images and Youtube Video of the post
  List<Widget> listMedia(BuildContext context, Post post) {
    return [
      if (post.youtubeId.isNotEmpty == true)
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  insetPadding: const EdgeInsets.all(0),
                  contentPadding: const EdgeInsets.all(0),
                  content: YouTube(youtubeId: post.youtubeId),
                );
              },
            );
          },
          child: YouTubeThumbnail(
            key: ValueKey(post.youtubeId),
            youtubeId: post.youtubeId,
            stackFit: StackFit.passthrough,
          ),
        ),
      ...post.urls.map((e) => CachedNetworkImage(imageUrl: e)).toList()
    ];
  }

  /// Update all post of the user
  void updateAllPostOfUser(String uid, {required Map<String, dynamic> data}) async {
    if (data.isEmpty) return;
    final snapshot = await postCol.where('uid', isEqualTo: uid).get();
    if (snapshot.size == 0) return;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, data);
    }
    return batch.commit();
  }

  // Shows the preview carousel of the media of the post
  void showPreview(BuildContext context, Post post, {int index = 0}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) {
        return CarouselScreen(
          widgets: listMedia(context, post),
          index: index,
        );
      },
    );
  }

  /// Returns a list of menu widgets on post view screen.
  ///
  List<Widget> postViewActions({
    required BuildContext context,
    required Post? post,
    Function(bool blocked)? onBlock,
  }) {
    if (post == null) return [];
    return [
      PopupMenuButton(
        icon: const Icon(Icons.more_horiz),
        itemBuilder: (context) => [
          // Removed temporarily. Please Uncomment when functionality is ready.
          // const PopupMenuItem(
          //   value: "adjust_text_size",
          //   child: Text("Adjust text size"),
          // ),
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
              child: UserBlocked(
                otherUid: post.uid,
                notBlockedBuilder: (context) {
                  return Text(tr.block);
                },
                blockedBuilder: (context) {
                  return Text(tr.unblock);
                },
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
              final blocked = my!.hasBlocked(post.uid);
              if (blocked) {
                await my!.unblock(post.uid);
              } else {
                await my!.block(post.uid);
              }
              final updatedBlocked = my!.hasBlocked(post.uid);
              toast(
                title: updatedBlocked ? tr.block : tr.unblock,
                message: updatedBlocked ? tr.blockMessage : tr.unblockMessage,
              );
              if (onBlock != null) onBlock(updatedBlocked);
              break;
            case 'copyId':
              await Clipboard.setData(ClipboardData(text: post.id));
              toast(title: 'Copy to clipboard', message: "${post.id} was copy to clipboard");
          }
        },
      ),
    ];
  }

  /// Callback function when a post is liked or unliked.
  /// send only when user liked the post.
  Future sendNotificationOnLike(Post post, bool isLiked) async {
    if (enableNotificationOnLike == false) return;

    if (isLiked == false) return;
    if (await UserSettingService.instance.hasUserSettingId(
      otherUid: post.uid,
      id: NotificationSettingConfig.disableNotifyOnPostLiked,
    )) return;

    MessagingService.instance.queue(
      title: "${my!.name} liked your post.",
      body: post.title,
      id: post.id,
      uids: [post.uid],
      type: NotificationType.post,
    );
  }
}
