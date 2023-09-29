import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  final String id;
  final String? uid, postId, commentId;
  final String reason;
  final String type;

  @FirebaseDateTimeConverter()
  @JsonKey(includeFromJson: true, includeToJson: true)
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reason,
    this.uid,
    this.postId,
    this.commentId,
    required this.type,
    dynamic createdAt,
  }) : createdAt = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();

  factory Report.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Report.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReportToJson(this);

  @override
  toString() => "Report(${toJson().toString()})";

  static ({String id, String type}) info({
    String? otherUid,
    String? postId,
    String? commentId,
  }) {
    String id = '$myUid-${postId ?? commentId ?? otherUid ?? ''}';

    String type = otherUid != null
        ? 'user'
        : postId != null
            ? 'post'
            : 'comment';

    return (id: id, type: type);
  }

// UserReview

  static Future<Report?> get(String id) async {
    final snapshot = await reportDoc(id).get();
    if (snapshot.exists == false) {
      return null;
    }
    return Report.fromDocumentSnapshot(snapshot);
  }

  /// Create a report
  ///
  /// Returns {exists: true, id: xxx } if the user has already reported on this object.
  ///
  /// See readme for details.
  ///
  static Future<String?> create({
    required String reason,
    String? otherUid,
    String? postId,
    String? commentId,
  }) async {
    final info = Report.info(
      commentId: commentId,
      otherUid: otherUid,
      postId: postId,
    );

    // check if the user has already reported on this object.
    try {
      final re = await get(info.id);
      if (re != null) {
        return null;
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        rethrow;
      }
    }

    final data = <String, dynamic>{
      'uid': myUid,
      'type': info.type,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (postId != null) {
      data['postId'] = postId;
    } else if (commentId != null) {
      data['commentId'] = commentId;
    } else if (otherUid != null) {
      data['otherUid'] = otherUid;
    }

    // print('data; $data');

    await reportDoc(info.id).set(data);
    return info.id;
  }
}
