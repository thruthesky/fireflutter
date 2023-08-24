import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/model/comment.dart';
import 'package:flutter/foundation.dart';

class CommentService with FirebaseHelper {
  static CommentService? _instance;
  static CommentService get instance => _instance ??= CommentService._();
  CommentService._();

  Future<Comment> createComment({
    required String postId,
    required String content,
    List<String>? files,
    Comment? replyTo,
    Comment? lastRootComment,
  }) {
    debugPrint('Last ROOT comment sort : ${lastRootComment?.sort}');
    return Comment.create(
      postId: postId,
      content: content,
      files: files,
      replyTo: replyTo?.id,
      sort: replyTo?.sort ?? lastRootComment?.sort,
      depth: replyTo != null ? replyTo.depth + 1 : 0,
    );
  }
}
