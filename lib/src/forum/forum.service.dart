import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ForumService {
  static ForumService? _instance;
  static ForumService get instance => _instance ??= ForumService._();

  ForumService._();

  Function(PostModel)? onPostCreate;
  Function(PostModel)? onPostUpdate;
  Function(PostModel)? onPostDelete;
  Function(CommentModel)? onCommentCreate;
  Function(CommentModel)? onCommentUpdate;
  Function(CommentModel)? onCommentDelete;

  init({
    Function(PostModel)? onPostCreate,
    Function(PostModel)? onPostUpdate,
    Function(PostModel)? onPostDelete,
    Function(CommentModel)? onCommentCreate,
    Function(CommentModel)? onCommentUpdate,
    Function(CommentModel)? onCommentDelete,
  }) {
    this.onPostCreate = onPostCreate;
    this.onPostUpdate = onPostUpdate;
    this.onPostDelete = onPostDelete;
    this.onCommentCreate = onCommentCreate;
    this.onCommentUpdate = onCommentUpdate;
    this.onCommentDelete = onCommentDelete;
  }

  Future showPostCreateScreen(BuildContext context, {required String category}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostEditScreen(
        category: category,
      ),
    );
  }

  Future showPostUpdateScreen(BuildContext context, {required PostModel post}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostEditScreen(
        post: post,
      ),
    );
  }

  Future showPostViewScreen(BuildContext context, {required PostModel post}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostViewScreen(
        post: post,
      ),
    );
  }

  /// Returns true if comment is created or updated.
  Future<bool?> showCommentCreateScreen(
    BuildContext context, {
    required PostModel post,
    CommentModel? parent,
    bool? showUploadDialog,
    bool? focusOnTextField,
  }) async {
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

  /// Returns true if comment is created or updated.
  Future<bool?> showCommentUpdateScreen(
    BuildContext context, {
    required CommentModel comment,
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
