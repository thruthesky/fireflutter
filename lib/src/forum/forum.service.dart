import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class ForumService {
  static ForumService? _instance;
  static ForumService get instance => _instance ??= ForumService._();

  ForumService._();

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

  Future showCommentCreateScreen(BuildContext context, {required PostModel post}) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => CommentEditDialog(
        post: post,
      ),
    );
  }
}
