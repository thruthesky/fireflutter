import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class Report {
  /// Paths and Refs
  static String nodeName = 'reports';

  static DatabaseReference root = FirebaseDatabase.instance.ref();
  static DatabaseReference reportsRef = root.child(nodeName);
  static DatabaseReference unviewedRef = reportsRef.child('unviewed');
  static DatabaseReference rejectsRef = reportsRef.child('rejected');

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
  String reportId;
  String rejectReason;

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
    required this.reportId,
    required this.rejectReason,
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
      reportId: json['reportId'] ?? '',
      rejectReason: json['rejectReason'] ?? '',
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
      'reportId': reportId,
    };
  }

  @override
  String toString() {
    return 'Report(uid: $uid, otherUserUid: $otherUserUid, chatRoomId: $chatRoomId, category: $category, postId: $postId, commentId: $commentId, reason: $reason, createdAt: $createdAt , reportId: $reportId, commentId: $commentId, reason: $reason, rejectReason: $rejectReason)';
  }

  // For REVIEW
  // Adding [reportId] to the report to have a track on report and when the admin
  // want to reject the report it will remove from report id
  // and create a report in the rejected node with the rejectReason for reason for
  // rejection
  static Future<void> reject(
      {required Report report, required String rejectReason}) async {
    await unviewedRef.child(report.reportId).remove();
    await rejectsRef.child(report.reportId).set({
      'uid': report.uid,
      'reason': report.reason,
      'otherUserUid': report.otherUserUid,
      'category': report.category,
      'postId': report.postId,
      'commentId': report.commentId,
      'chatRoomId': report.chatRoomId,
      'createdAt': report.createdAt,
      'reportId': report.reportId,
      'rejectReason': rejectReason
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

    // refactor code need to Review
    // generate key first and report id
    DatabaseReference newReportRef = unviewedRef.push();
    String reportId = newReportRef.key!;

    Map<String, dynamic> reportData = {
      'uid': myUid!,
      'reason': reason,
      'otherUserUid': otherUserUid,
      'category': category,
      'postId': postId,
      'commentId': commentId,
      'chatRoomId': chatRoomId,
      'createdAt': ServerValue.timestamp,
      'reportId': reportId
    };

    return await newReportRef.set(reportData);
  }
}
