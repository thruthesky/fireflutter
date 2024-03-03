import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class Report {
  /// Paths and Refs
  static String nodeName = 'reports';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference reportsRef = root.child(nodeName);

  /// Variables
  String key;
  String uid;
  String? otherUserUid;
  String? chatRoomId;
  String? postId;
  String? category;
  String? commentId;
  String reason;
  final int createdAt;

  bool get isPost => category != null;
  bool get isComment => commentId != null;
  bool get isUser => otherUserUid != null;
  bool get isChatRoom => chatRoomId != null;

  Report({
    required this.key,
    required this.uid,
    required this.otherUserUid,
    required this.chatRoomId,
    required this.category,
    required this.postId,
    required this.commentId,
    required this.reason,
    required this.createdAt,
  });

  factory Report.fromJson(Map<dynamic, dynamic> json, String key) {
    return Report(
      key: key,
      uid: json['uid'],
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      category: json['category'],
      postId: json['postId'],
      commentId: json['commentId'],
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] as int,
    );
  }

  factory Report.fromValue(dynamic value, String key) {
    return Report.fromJson(value, key);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'otherUserUid': otherUserUid,
      'chatRoomId': chatRoomId,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'reason': reason,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Report(uid: $uid, otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, category: $category, postId: $postId, commentId: $commentId, reason: $reason, createdAt: $createdAt)';
  }

  static Future<void> create({
    String? otherUserUid,
    String? chatRoomId,
    String? category,
    String? postId,
    String? commentId,
    String reason = '',
  }) async {
    if (postId != null) {
      if (commentId == null && category == null) {
        throw ArgumentError(
            'category or commentId must be provided when postId is provided');
      }
    }
    return await Report.reportsRef.push().set({
      'uid': myUid!,
      'reason': reason,
      'otherUserUid': otherUserUid,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
    });
  }
}
