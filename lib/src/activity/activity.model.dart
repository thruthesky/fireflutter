import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ActivityModel {
  final String? otherUserUid;
  final String? category;
  final String? postId;
  final String? commentId;
  final int createdAt;

  const ActivityModel({
    this.otherUserUid,
    this.category,
    this.postId,
    this.commentId,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      otherUserUid: json['otherUserUid'] as String?,
      category: json['category'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  static Future<void> userView(String otherUserUid) async {
    if (myUid == null) return;
    if (ActivityService.instance.userView == false) return;
    return await Ref.userViewActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': otherUserUid,
    });
  }

  static Future<void> userLike(String otherUserUid) async {
    if (myUid == null) return;
    if (ActivityService.instance.userLike == false) return;
    return await Ref.userLikeActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': otherUserUid,
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
    if (ActivityService.instance.postCreate == false) return;
    return await Ref.postCreateActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'category': category,
      'postId': postId,
    });
  }

  /// Create a new post
  ///
  /// It logs the activity and sends a notification to the followers.
  static Future<void> commentCreate({
    required String postId,
    required String commentId,
  }) async {
    if (myUid == null) return;
    if (ActivityService.instance.commentCreate == false) return;
    return await Ref.commentCreateActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'postId': postId,
      'commentId': commentId,
    });
  }
}
