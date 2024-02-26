import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ActionModel {
  final String key;
  final String? category;
  final String? postId;
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
    if (ActionService.instance.userView.enable == false) return;

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
    if (ActionService.instance.chatJoin.enable == false) return;

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
    if (ActionService.instance.postCreate.enable == false) return;

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
    if (ActionService.instance.commentCreate.enable == false) return;
    final ref = Ref.commentCreateAction.child(commentId);
    return await ref.set({
      'createdAt': ServerValue.timestamp,
      'postId': postId,
    });
  }
}
