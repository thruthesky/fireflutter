import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumService {
  static ForumService? _instance;
  static ForumService get instance => _instance ??= ForumService._();

  ForumService._();

  Function(Post)? onPostCreate;
  Function(Post)? onPostUpdate;
  Function(Post)? onPostDelete;
  Function(Comment)? onCommentCreate;
  Function(Comment)? onCommentUpdate;
  Function(Comment)? onCommentDelete;

  init({
    Function(Post post)? onPostCreate,
    Function(Post post)? onPostUpdate,
    Function(Post post)? onPostDelete,
    Function(Comment comment)? onCommentCreate,
    Function(Comment comment)? onCommentUpdate,
    Function(Comment comment)? onCommentDelete,
  }) {
    this.onPostCreate = onPostCreate;
    this.onPostUpdate = onPostUpdate;
    this.onPostDelete = onPostDelete;
    this.onCommentCreate = onCommentCreate;
    this.onCommentUpdate = onCommentUpdate;
    this.onCommentDelete = onCommentDelete;
  }

  /// Show post create screen when the user taps on the post creation button
  ///
  ///
  Future showPostCreateScreen({
    required BuildContext context,
    required String category,
  }) async {
    if (iam.disabled) {
      error(context: context, message: 'You are disabled.');
      return;
    }

    if (ActionLogService.instance.postCreate[category] != null) {
      if (await ActionLogService.instance.postCreate[category]!.isOverLimit()) {
        return;
      }
    }

    if (ActionLogService.instance.postCreate['all'] != null) {
      /// 만약 'all' 카테고리가 제한이 되었으면, 모든 게시판을 통틀어서 제한이 되었는지 확인한다.
      if (await ActionLogService.instance.postCreate['all']!.isOverLimit()) {
        return;
      }
    }

    if (context.mounted) {
      await showGeneralDialog(
        context: context,
        pageBuilder: ($, $$, $$$) => PostEditScreen(
          category: category,
        ),
      );
    }
  }

  Future showPostUpdateScreen({
    required BuildContext context,
    required Post post,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostEditScreen(
        post: post,
      ),
    );
  }

  Future showPostViewScreen({
    required BuildContext context,
    required Post post,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostViewScreen(
        post: post,
      ),
    );
  }

  /// Returns true if comment is created or updated.
  Future<bool?> showCommentCreateScreen({
    required BuildContext context,
    required Post post,
    Comment? parent,
    bool? showUploadDialog,
    bool? focusOnTextField,
  }) async {
    if (iam.disabled) {
      error(context: context, message: 'You are disabled.');
      return false;
    }
    if (await ActionLogService.instance.commentCreate.isOverLimit()) {
      return false;
    }
    if (context.mounted) {
      return showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true, // 중요: 이것이 있어야 키보드가 bottom sheet 을 위로 밀어 올린다.
        builder: (_) => CommentEditDialog(
          post: post,
          parent: parent,
          showUploadDialog: showUploadDialog,
          focusOnTextField: focusOnTextField,
        ),
      );
    }
    return null;
  }

  /// Returns true if comment is created or updated.
  Future<bool?> showCommentUpdateScreen({
    required BuildContext context,
    required Comment comment,
    bool? showUploadDialog,
    bool? focusOnTextField,
  }) async {
    return showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true, // 중요: 이것이 있어야 키보드가 bottom sheet 을 위로 밀어 올린다.
      builder: (_) => CommentEditDialog(
        comment: comment,
        showUploadDialog: showUploadDialog,
        focusOnTextField: focusOnTextField,
      ),
    );
  }
}
