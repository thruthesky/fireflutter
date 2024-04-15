import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Bookmark {
  /// Paths and Refs
  static const String node = 'bookmarks';

  /// Bookmark ( = Favorite )
  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();
  static DatabaseReference bookmarksRef = rootRef.child(node);
  static String bookmarkUser(String otherUserUid) =>
      '$node/$myUid/$otherUserUid';
  static String bookmarkPost(String postId) => '$node/$myUid/$postId';
  static String bookmarkComment(String commentId) => '$node/$myUid/$commentId';
  static String bookmarkChatRoom(String roomId) => '$node/$myUid/$roomId';

  static DatabaseReference commentRef(String commentId) =>
      rootRef.child(bookmarkComment(commentId));
  static DatabaseReference postRef(String postId) =>
      rootRef.child(bookmarkPost(postId));

  static DatabaseReference userRef(String otherUserUid) =>
      rootRef.child(bookmarkUser(otherUserUid));

  /// Variables
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

  Bookmark({
    required this.key,
    required this.otherUserUid,
    required this.chatRoomId,
    required this.category,
    required this.postId,
    required this.commentId,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<dynamic, dynamic> json, String key) {
    return Bookmark(
      key: key,
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      category: json['category'],
      postId: json['postId'],
      commentId: json['commentId'],
      createdAt: json['createdAt'] as int,
    );
  }

  factory Bookmark.fromValue(dynamic value, String key) {
    return Bookmark.fromJson(value, key);
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
    return 'Bookmark(otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, category: $category, postId: $postId, commentId: $commentId, createdAt: $createdAt)';
  }

  static Future<Bookmark?> get({
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

    final snapshot = await Bookmark.bookmarksRef.child(myUid!).child(id).get();

    if (!snapshot.exists) {
      return null;
    }

    return Bookmark.fromValue(snapshot.value, snapshot.key!);
  }

  /// Toggle bookmark
  ///
  /// If the bookmark exists, it will be deleted. If not, it will be created.
  ///
  /// Returns true if the bookmark is created, false if the bookmark is deleted.
  static Future<bool?> toggle({
    required BuildContext context,
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'bookmark-toggle',
          data: {
            'otherUserUid': otherUserUid,
            'chatRoomId': chatRoomId,
            'category': category,
            'postId': postId,
            'commentId': commentId,
          });
      if (re != true) return null;
    }

    final bookmark = await get(
      otherUserUid: otherUserUid,
      chatRoomId: chatRoomId,
      category: category,
      postId: postId,
      commentId: commentId,
    );
    if (bookmark == null) {
      await _create(
        otherUserUid: otherUserUid,
        chatRoomId: chatRoomId,
        category: category,
        postId: postId,
        commentId: commentId,
      );
      return true;
    } else {
      await _delete(
        otherUserUid: otherUserUid,
        chatRoomId: chatRoomId,
        category: category,
        postId: postId,
        commentId: commentId,
      );
      return false;
    }
  }

  static Future<void> _create({
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

    return await bookmarksRef.child(myUid!).child(id).set({
      'otherUserUid': otherUserUid,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> _delete({
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

    return await bookmarksRef.child(myUid!).child(id).remove();
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
