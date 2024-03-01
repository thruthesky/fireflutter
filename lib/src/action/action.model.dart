import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

/// ActionModel
///
/// 액션 모델은, 사용자의 활동을 기록하는 모델이다.
/// Fireship 의 적절한 위치에서 이 모델의 [userProfileView], [chatJoin], [postCreate], [commentCreate] 등의 함수를
/// 호출하여 사용자의 활동을 기록하면 된다.
class ActionModel {
  final String key;

  /// [category] 는 게시판의 경우만 필요하다. key 가 게시판의 id 이다.
  final String? category;

  /// [postId] 는 코멘트의 경우만 필요하다. key 가 코멘트의 id 이다.
  final String? postId;

  ///
  final int createdAt;

  const ActionModel({
    required this.key,
    this.category,
    this.postId,
    required this.createdAt,
  });

  factory ActionModel.fromJson(Map<Object?, Object?> json, String key) {
    return ActionModel(
      key: key,
      category: json['category'] as String?,
      postId: json['postId'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  factory ActionModel.fromSnapshot(DataSnapshot snapshot) {
    return ActionModel.fromJson(snapshot.value as Map, snapshot.key!);
  }

  static Future<void> userView(String otherUserUid) async {
    if (myUid == null) return;
    if (ActionService.instance.userProfileView.ref == null) return;

    final ref = Ref.userViewAction.child(otherUserUid);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return;
    }

    return await ref.set({
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> chatJoin(String roomId) async {
    if (myUid == null) return;
    if (ActionService.instance.chatJoin.ref == null) return;

    final ref = Ref.chatJoinAction.child(roomId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return;
    }

    return await ref.set({
      'createdAt': ServerValue.timestamp,
    });
  }

  /// Create a new post
  ///
  /// It logs the activity and sends a notification to the followers.
  static Future<void> postCreate({
    required String category,
    required String postId,
  }) async {
    if (myUid == null) return;
    if (ActionService.instance.postCreate.ref == null) return;

    final ref = Ref.postCreateAction.child(postId);

    return await ref.set({
      'createdAt': ServerValue.timestamp,
      'category': category,
    });
  }

  static Future<void> commentCreate({
    required String postId,
    required String commentId,
  }) async {
    if (myUid == null) return;
    if (ActionService.instance.commentCreate.ref == null) return;
    final ref = Ref.commentCreateAction.child(commentId);
    return await ref.set({
      'createdAt': ServerValue.timestamp,
      'postId': postId,
    });
  }
}
