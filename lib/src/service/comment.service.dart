import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentService with FirebaseHelper {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();
  CommentService._();

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
}
