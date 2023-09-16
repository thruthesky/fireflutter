import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentService {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();
  CommentService._();

  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;

  Function(Comment)? onCreate;
  Function(Comment)? onUpdate;

  init({
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
    void Function(Comment)? onCreate,
    void Function(Comment)? onUpdate,
  }) {
    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;
    this.uploadFromFile = uploadFromFile;

    this.onCreate = onCreate;
    this.onUpdate = onUpdate;
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
  }) {
    return showModalBottomSheet<Comment?>(
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
                post: post,
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
  showCommentViewDialog({required BuildContext context, Comment? comment, String? commentId}) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, _, __) => CommentViewScreen(
        comment: comment,
        commentId: commentId,
      ),
    );
  }
}
