import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class Report {
  /// Paths and Refs
  static String nodeName = 'reports';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference reportsRef = root.child(nodeName);
  static DatabaseReference unviewedRef = reportsRef.child('unviewed');
  static DatabaseReference rejectedRef = reportsRef.child('rejected');
  static DatabaseReference acceptedRef = reportsRef.child('accepted');

  /// Variables
  DatabaseReference ref;
  String uid;
  String? otherUserUid;
  String? chatRoomId;
  String? postId;
  String? category;
  String? commentId;
  String reason;
  final int createdAt;
  String review;

  bool get isPost => category != null;
  bool get isComment => commentId != null;
  bool get isUser => otherUserUid != null;
  bool get isChatRoom => chatRoomId != null;

  bool get rejected => ref.parent?.key == 'rejected';
  bool get accepted => ref.parent?.key == 'accepted';
  bool get unviewed => ref.parent?.key == 'unviewed';

  Report({
    required this.ref,
    required this.uid,
    required this.otherUserUid,
    required this.chatRoomId,
    required this.category,
    required this.postId,
    required this.commentId,
    required this.reason,
    required this.createdAt,
    required this.review,
  });

  factory Report.fromJson(Map<dynamic, dynamic> json, DatabaseReference ref) {
    return Report(
      ref: ref,
      uid: json['uid'],
      otherUserUid: json['otherUserUid'],
      chatRoomId: json['chatRoomId'],
      category: json['category'],
      postId: json['postId'],
      commentId: json['commentId'],
      reason: json['reason'] ?? '',
      createdAt: json['createdAt'] as int,
      review: json['review'] ?? '',
    );
  }

  /// This is a factory constructor that creates a Report from a value and a key
  ///
  /// [value] is the data
  ///
  /// [key] is the key of the data
  factory Report.fromValue(dynamic value, DatabaseReference ref) {
    return Report.fromJson(value, ref);
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
      'review': review
    };
  }

  @override
  String toString() {
    return 'Report(uid: $uid, otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, category: $category, postId: $postId, commentId: $commentId, reason: $reason, createdAt: $createdAt ,commentId: $commentId, reason: $reason, review: $review)';
  }

  /// When the admin want to rejected/accepted the report it will remove from the unviewd list
  /// and create a report in the rejected/accepted node with the review of the admin
  /// [review] is the message from the admin why the admin rejected/accpeted the reports.
  ///
  static Future<void> reject({
    required Report report,
    required String review,
  }) async {
    await rejectedRef.child(report.ref.key!).set(report.toJson());
    await report.ref.remove();
  }

  static Future<void> accept({
    required Report report,
    required String review,
  }) async {
    final ref = acceptedRef.child(report.ref.key!);
    print('ref: ${ref.path}');
    print('report: ${report.toJson()}');
    await ref.set(report.toJson());
    await report.ref.remove();
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
    return await unviewedRef.push().set({
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
