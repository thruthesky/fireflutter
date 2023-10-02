import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentService {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();
  CommentService._();

  CommentCustomize customize = CommentCustomize();

  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;

  Function(Comment)? onCreate;
  Function(Comment)? onUpdate;

  // Enable/Disable push notification when post is liked
  bool sendNotificationOnLike = true;

  init({
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
    void Function(Comment)? onCreate,
    void Function(Comment)? onUpdate,
    CommentCustomize? customize,
    bool sendNotificationOnLike = true,
  }) {
    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;
    this.uploadFromFile = uploadFromFile;

    this.onCreate = onCreate;
    this.onUpdate = onUpdate;

    this.sendNotificationOnLike = sendNotificationOnLike;

    if (customize != null) {
      this.customize = customize;
    }
  }

  Future<Comment> createComment({
    required Post post,
    required String content,
    List<String>? urls,
    Comment? parent,
  }) async {
    return await Comment.create(
      post: post,
      content: content,
      urls: urls,
      parent: parent,
    );
  }

  /// Show bottom sheet to create or update a comment.
  ///
  /// [post] is the post to which the comment is created or updated under.
  /// [parent] is the parent comment of the comment to be created.
  /// [comment] is the comment to be updated.
  Future<Comment?> showCommentEditBottomSheet(
    BuildContext context, {
    Post? post,
    Comment? parent,
    Comment? comment,
  }) async {
    if (notLoggedIn) {
      toast(title: tr.loginFirstTitle, message: tr.loginFirstMessage);
      return null;
    }
    return customize.showCommentEditBottomSheet?.call(context, post: post, parent: parent, comment: comment) ??
        showModalBottomSheet<Comment?>(
          context: context,
          // To prevent the bottom sheet from being hidden by the keyboard.
          isScrollControlled: true,
          // backgroundColor: primaryContainer,
          // barrierColor: secondary.withOpacity(.5).withAlpha(110),
          isDismissible: true,
          builder: (context) => Padding(
            // This padding is important to prevent the bottom sheet from being hidden by the keyboard.
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SafeArea(
              // SafeArea is needed for Simulator
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  CommentEditBottomSheet(
                    parent: parent,
                    comment: comment,
                    onEdited: (comment) => Navigator.of(context).pop(comment),
                  ),
                  // This is for simulator
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
  }

  /// Display a commnet view dialog
  ///
  /// This displays a single comments.
  showCommentViewDialog({required BuildContext context, Comment? comment, String? commentId}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CommentViewScreen(
        comment: comment,
        commentId: commentId,
      ),
    );
  }

  /// Display a bottom sheet for the comment list of the post
  ///
  showCommentListBottomSheet(
    BuildContext context,
    Post post,
  ) {
    customize.showCommentListBottomSheet?.call(context, post) ??
        showModalBottomSheet(
          context: context,
          builder: (context) => CommentListBottomSheet(
            post: post,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        );
  }

  /// Callback function when a comment is liked or unliked.
  /// send only when user liked the comment.
  Future onToggleLike(Comment comment, bool isLiked) async {
    if (!sendNotificationOnLike) return;
    if (!isLiked) return;
    if (!loggedIn) return;
    MessagingService.instance.queue(
      title: comment.content,
      body: "${my.name} liked your post",
      id: myUid,
      uids: [comment.uid],
      type: NotificationType.post.name,
    );
  }
}
