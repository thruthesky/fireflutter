import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class ActivityLog {
  /// Paths and Refs
  static const String node = 'activity-logs';
  static String get chatJoinPath => '$node/$myUid/chat-join';
  static String get commentCreatePath => '$node/$myUid/comment-create';
  static String get postCreatePath => '$node/$myUid/post-create';
  static String get userLikePath => '$node/$myUid/user-like';
  static String get userProfileViewPath => '$node/$myUid/user-profile-view';
  static categoryCreateRef(String category) =>
      root.child(postCreatePath).child(category);

  ///
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(node);
  static DatabaseReference chatJoinRef = root.child(chatJoinPath);
  static DatabaseReference commentCreateRef = root.child(commentCreatePath);
  static DatabaseReference postCreateRef = root.child(postCreatePath);
  static DatabaseReference userLikeRef = root.child(userLikePath);
  static DatabaseReference whoLikedMeRef(String otherUserUid) =>
      root.child('$node/$otherUserUid/who-liked-me');
  static DatabaseReference userProfileViewRef = root.child(userProfileViewPath);

  static DatabaseReference whoViewedMeRef(String otherUserUid) =>
      root.child('$node/$otherUserUid/who-viewed-me');

  /// Variables
  final String? otherUserUid;
  final String? category;
  final String? postId;
  final String? commentId;
  final int createdAt;

  const ActivityLog({
    this.otherUserUid,
    this.category,
    this.postId,
    this.commentId,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      otherUserUid: json['otherUserUid'] as String?,
      category: json['category'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  /// User profile view activity
  ///
  /// 기록을 할 때, 사용자 A 가 B 의 프로필을 보면, 쌍방기록을 한다.
  /// 즉, A 가 B 를 본 기록을 기록하고, B 가 A 를 기록을 한다.
  /// 그래서 누가 나를 봤는지 기록한다.
  static Future<void> userProfileView(String otherUserUid) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.userProfileView == false) return;

    /// 내가 다른 사용자 프로필을 본 경우 기록
    await userProfileViewRef.push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': otherUserUid,
    });

    /// 다른 사용자가 나를 본 경우 기록. (누가 나를 보았는지 기록)
    final newRef = whoViewedMeRef(otherUserUid).push();
    final data = {
      'createdAt': ServerValue.timestamp,
      'otherUserUid': myUid,
    };
    try {
      await newRef.set(data);
    } catch (e) {
      dog("ActivityLog.userProfileView: $e, path: ${newRef.path}, data: $data");
      rethrow;
    }
  }

  static Future<void> userLike(String otherUserUid, bool re) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.userLike == false) return;

    /// 내가 다른 사용자 좋아요 한 기록
    await userLikeRef.push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': myUid,
      're': re,
    });

    /// 누가 나를 좋아요 했는지 기록
    await whoLikedMeRef(otherUserUid).push().set({
      'createdAt': ServerValue.timestamp,
      'otherUserUid': myUid,
      're': re,
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
    return await postCreateRef.push().set({
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
    return await commentCreateRef.push().set({
      'createdAt': ServerValue.timestamp,
      'postId': postId,
      'commentId': commentId,
    });
  }

  /// chat join(enter) activity
  static Future<void> chatJoin(String roomId) async {
    if (myUid == null) return;
    if (ActivityLogService.instance.chatJoin == false) return;
    return await chatJoinRef.push().set({
      'createdAt': ServerValue.timestamp,
      'roomId': roomId,
    });
  }
}
