import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// types of report
enum ReportType { rejected, accepted }

/// Where the report originated
enum From { rejeced, accepted, unviewed }

class Report {
  /// Paths and Refs
  static String nodeName = 'reports';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference reportsRef = root.child(nodeName);
  static DatabaseReference unviewedRef = reportsRef.child('unviewed');
  static DatabaseReference rejectedRef = reportsRef.child('rejected');
  static DatabaseReference acceptedRef = reportsRef.child('accepted');

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
  String review;

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
    required this.review,
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
      review: json['review'] ?? '',
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
  /// [ReportType] is the type of the report thier are two types of reports:
  /// - ReportType.rejected is thre rejected reports and will go into the rejected node.
  /// - ReportType.accepted is the accepted reports and will go into the accepted node.
  ///
  /// [From] is where the report originated before evaluated, by default when the report is
  /// created the report will originated in the unviewed node which is From.unviewed
  /// and theres From.rejected and From.accepted
  static Future<void> evaluate({
    required Report report,
    required String review,
    required ReportType type,
    required From from,
  }) async {
    DatabaseReference ref;

    if (type == ReportType.rejected) {
      ref = rejectedRef;
    } else if (type == ReportType.accepted) {
      ref = acceptedRef;
    } else {
      throw Issue('Invalid', 'Invalid Type');
    }

    if (from == From.unviewed) {
      await unviewedRef.child(report.key).remove();
    } else if (from == From.rejeced) {
      await rejectedRef.child(report.key).remove();
    } else if (from == From.accepted) {
      await acceptedRef.child(report.key).remove();
    }

    await ref.child(report.key).set({
      'uid': report.uid,
      'reason': report.reason,
      'otherUserUid': report.otherUserUid,
      'category': report.category,
      'postId': report.postId,
      'commentId': report.commentId,
      'chatRoomId': report.chatRoomId,
      'createdAt': report.createdAt,
      'review': review
    });
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
