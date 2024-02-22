import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class BookmarkModel {
  String key;
  String? otherUserUid;
  String? chatRoomId;
  String? postId;
  String? category;
  String? commentId;

  final int createdAt;

  bool get isPost => category != null;
  bool get isComment => commentId != null;
  bool get isUser => otherUserUid != null;
  bool get isChatRoom => chatRoomId != null;

  BookmarkModel({
    required this.key,
    required this.otherUserUid,
    required this.chatRoomId,
    required this.category,
    required this.postId,
    required this.commentId,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<dynamic, dynamic> json, String key) {
    return BookmarkModel(
      key: key,
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      category: json['category'],
      postId: json['postId'],
      commentId: json['commentId'],
      createdAt: json['createdAt'] as int,
    );
  }

  factory BookmarkModel.fromValue(dynamic value, String key) {
    return BookmarkModel.fromJson(value, key);
  }

  Map<String, dynamic> toJson() {
    return {
      'otherUserUid': otherUserUid,
      'chatRoomId': chatRoomId,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'BookmarkModel(otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, category: $category, postId: $postId, commentId: $commentId, createdAt: $createdAt)';
  }

  static Future<BookmarkModel?> get({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) async {
    String id = _getId(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      category: category,
      postId: postId,
      commentId: commentId,
    );

    final snapshot = await Ref.bookmarks.child(myUid!).child(id).get();

    if (!snapshot.exists) {
      return null;
    }

    return BookmarkModel.fromValue(snapshot.value, snapshot.key!);
  }

  static Future<bool> toggle({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) async {
    final bookmark = await get(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      category: category,
      postId: postId,
      commentId: commentId,
    );
    if (bookmark == null) {
      await create(
        otherUserUid: otherUserUid,
        chatRoomId: chatRoomId,
        category: category,
        postId: postId,
        commentId: commentId,
      );
      return true;
    } else {
      await delete(
        otherUserUid: otherUserUid,
        chatRoomId: chatRoomId,
        category: category,
        postId: postId,
        commentId: commentId,
      );
    }
    return false;
  }

  static Future<void> create({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) async {
    String id = _getId(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      category: category,
      postId: postId,
      commentId: commentId,
    );

    return await Ref.bookmarks.child(myUid!).child(id).set({
      'otherUserUid': otherUserUid,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> delete({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) async {
    String id = _getId(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      category: category,
      postId: postId,
      commentId: commentId,
    );

    return await Ref.bookmarks.child(myUid!).child(id).remove();
  }

  static String _getId({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) {
    if (postId != null) {
      if (commentId == null && category == null) {
        throw ArgumentError(
            'category or commentId must be provided when postId is provided');
      }
    }
    if (category != null) {
      return postId!;
    } else if (commentId != null) {
      return commentId;
    } else if (chatRoomId != null) {
      return chatRoomId;
    } else if (otherUserUid != null) {
      return otherUserUid;
    } else {
      throw ArgumentError(
          'postId, commentId, chatRoomId, or otherUserUid must be provided');
    }
  }
}
