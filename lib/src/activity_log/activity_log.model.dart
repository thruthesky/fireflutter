import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class ActivityLogModel {
  /// Paths and Refs
  static const String path = 'activity-logs';
  static String get userProfileViewPath => '$path/user-profile-view/$myUid';
  static String get chatJoinPath => '$path/chat-join/$myUid';
  static String get postCreatePath => '$path/post-create/$myUid';
  static String get commentCreatePath => '$path/comment-create/$myUid';
  static categoryCreateRef(String category) =>
      root.child(postCreatePath).child(category);

  ///
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(path);
  static DatabaseReference userProfileViewRef = root.child(userProfileViewPath);
  static DatabaseReference chatJoinRef = root.child(chatJoinPath);
  static DatabaseReference postCreateRef = root.child(postCreatePath);
  static DatabaseReference commentCreateRef = root.child(commentCreatePath);

  /// Variables
  final String? otherUserUid;
  final String? category;
  final String? postId;
  final String? commentId;
  final int createdAt;

  const ActivityLogModel({
    this.otherUserUid,
    this.category,
    this.postId,
    this.commentId,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      otherUserUid: json['otherUserUid'] as String?,
      category: json['category'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  static Future<void> userView(String otherUserUid) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.userView == false) return;
    return await Ref.userViewActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': otherUserUid,
    });
  }

  static Future<void> userLike(String otherUserUid) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.userLike == false) return;
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
    if (ActivityLogService.instance.postCreate == false) return;
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
    if (ActivityLogService.instance.commentCreate == false) return;
    return await Ref.commentCreateActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'postId': postId,
      'commentId': commentId,
    });
  }

  /// chat join(enter) activity
  static Future<void> chatJoin(String roomId) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.chatJoin == false) return;
    return await Ref.chatJoinActivity.push().set({
      'createdAt': ServerValue.timestamp,
      'roomId': roomId,
    });
  }
}
