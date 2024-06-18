import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForumService {
  static ForumService? _instance;
  static ForumService get instance => _instance ??= ForumService._();

  /// Returns the RTDB refererence to the forum category push notification path for the category
  /// of the login user
  ///
  /// Save this path to true to subscribe the push notifications for the category.
  /// And delete it for unsubscribing from the push notifications.
  static DatabaseReference categoryPushNotificationPath(String category) =>
      FirebaseDatabase.instance
          .ref('post-subscriptions')
          .child(category)
          .child(myUid!);

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

  showForumChatScreen(
      {required BuildContext context,
      required String category,
      required String title}) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) =>
          ForumChatViewScreen(title: title, category: category),
    );
  }

  /// Show post create screen when the user taps on the post creation button
  ///
  ///
  Future showPostCreateScreen({
    required BuildContext context,
    required String category,
    String? group,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'showPostCreateScreen',
          data: {
            'category': category,
          });
      if (re != true) return;
    }

    if (iam.disabled) {
      error(context: context, message: 'You are disabled.');
      return;
    }

    if (ActionLogService.instance.postCreate[category] != null) {
      if (await ActionLogService.instance.postCreate[category]!
          .isOverLimit(category: category)) {
        return;
      }
    }

    if (ActionLogService.instance.postCreate['all'] != null) {
      /// 만약 'all' 카테고리가 제한이 되었으면, 모든 게시판을 통틀어서 제한이 되었는지 확인한다.
      if (await ActionLogService.instance.postCreate['all']!
          .isOverLimit(category: 'all')) {
        return;
      }
    }

    if (context.mounted) {
      await showGeneralDialog(
        context: context,
        pageBuilder: ($, $$, $$$) => PostEditScreen(
          category: category,
          group: group,
        ),
      );
    }
  }

  Future showPostUpdateScreen({
    required BuildContext context,
    required Post post,
    String? group,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostEditScreen(
        post: post,
        group: group,
      ),
    );
  }

  Future showPostViewScreen({
    required BuildContext context,
    required Post post,
    bool commentable = true,
  }) async {
    await showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => PostViewScreen(
        post: post,
        commentable: commentable,
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
    /// 로그인 확인
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'showCommentCreateScreen',
          data: {
            'post': post,
            'parent': parent,
            'showUploadDialog': showUploadDialog,
            'focusOnTextField': focusOnTextField,
          });
      if (re != true) return false;
    }

    /// 관리자에 의해 차단되었는지 확인
    if (iam.disabled) {
      error(context: context, message: 'You are disabled.');
      return false;
    }

    /// 코멘트 생성 제한 확인
    if (await ActionLogService.instance.commentCreate.isOverLimit()) {
      return false;
    }

    ///
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
    /// 로그인 확인
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'showCommentUpdateScreen',
          data: {
            'comment': comment,
            'showUploadDialog': showUploadDialog,
            'focusOnTextField': focusOnTextField,
          });
      if (re != true) return false;
    }

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
