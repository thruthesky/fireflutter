import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// ActionLogModel
///
/// 액션 모델은, 사용자의 활동을 기록하는 모델이다.
/// Fireship 의 적절한 위치에서 이 모델의 [userProfileView], [chatJoin], [postCreate], [commentCreate] 등의 함수를
/// 호출하여 사용자의 활동을 기록하면 된다.
class ActionLogModel {
  /// Paths and Refs
  ///
  static const String path = 'action-logs';
  static String get userProfileViewPath => '$path/user-profile-view/$myUid';
  static String get chatJoinPath => '$path/chat-join/$myUid';
  static String get postCreatePath => '$path/post-create/$myUid';
  static String get commentCreatePath => '$path/comment-create/$myUid';
  static categoryCreateRef(String category) =>
      root.child(postCreatePath).child(category);
  //
  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference ref = root.child(path);
  static DatabaseReference userProfileViewRef = root.child(userProfileViewPath);
  static DatabaseReference chatJoinRef = root.child(chatJoinPath);
  static DatabaseReference postCreateRef = root.child(postCreatePath);
  static DatabaseReference commentCreateRef = root.child(commentCreatePath);

  /// Member Variables
  final String key;

  /// [category] 는 게시판의 경우만 필요하다. key 가 게시판의 id 이다.
  final String? category;

  /// [postId] 는 코멘트의 경우만 필요하다. key 가 코멘트의 id 이다.
  final String? postId;

  ///
  final int createdAt;

  const ActionLogModel({
    required this.key,
    this.category,
    this.postId,
    required this.createdAt,
  });

  factory ActionLogModel.fromJson(Map<Object?, Object?> json, String key) {
    return ActionLogModel(
      key: key,
      category: json['category'] as String?,
      postId: json['postId'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  factory ActionLogModel.fromSnapshot(DataSnapshot snapshot) {
    return ActionLogModel.fromJson(snapshot.value as Map, snapshot.key!);
  }

  /// Create a new action log for user profiel view
  static Future<void> userProfileView(String otherUserUid) async {
    if (myUid == null) return;
    if (ActionLogService.instance.userProfileView.ref == null) return;
    final ref = userProfileViewRef.child(otherUserUid);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return;
      }
      return await ref.set({
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      dog('----> ActionLogModel.userProfileView() Error: $e, path: ${ref.path}');
      rethrow;
    }
  }

  /// Create a new action log for chat join
  static Future<void> chatJoin(String roomId) async {
    if (myUid == null) return;
    if (ActionLogService.instance.chatJoin.ref == null) return;

    final ref = chatJoinRef.child(roomId);

    try {
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return;
      }
      return await ref.set({
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      dog('----> ActionLogModel.chatJoin() Error: $e, path: ${ref.path}');
      rethrow;
    }
  }

  /// Create a new action log for post creation
  ///
  ///
  static Future<void> postCreate({
    required String category,
    required String postId,
  }) async {
    if (myUid == null) return;

    /// 글 생성 액션 기록 설정이 없으면, 그냥 리턴.
    ///
    /// 그래서, 만약, 전체 기록만 남길 수 없고, 설정이 되어져 있다면, 모든 카테고리를 다 기록한다.
    /// 제한 할 때에만, 특정 카테고리를 제한 할 수 있다.
    if (ActionLogService.instance.postCreate.isEmpty) {
      return;
      // if (await ActionLogService.instance.postCreate[category]!.isOverLimit()) {
      //   return;
      // }
    }

    /// For logging all posts
    final ref = categoryCreateRef('all').child(postId);
    final categoryRef = categoryCreateRef(category).child(postId);

    try {
      await ref.set({
        'createdAt': ServerValue.timestamp,
      });

      /// For logging category specific posts
      await categoryRef.set({
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      dog('----> ActionLogModel.postCreate() Error: $e, path: ${ref.path}');
      rethrow;
    }
  }

  /// Create a new action log for comment creation
  static Future<void> commentCreate({
    required String postId,
    required String commentId,
  }) async {
    if (myUid == null) return;
    if (ActionLogService.instance.commentCreate.ref == null) return;
    final ref = commentCreateRef.child(commentId);
    try {
      return await ref.set({
        'createdAt': ServerValue.timestamp,
        'postId': postId,
      });
    } catch (e) {
      dog('----> ActionLogModel.commentCreate() Error: $e, path: ${ref.path}');
      rethrow;
    }
  }
}
