import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  final String id;

  /// The reporter's uid
  final String? uid;

  /// the id of the post/comment/user that was reported.
  final String? otherUid, postId, commentId;

  /// The user's reason why the post/comment/user was reported.
  final String reason;

  /// The status if the report was already resolved by the admin.
  final bool resolved;

  /// The type of the report. Can be post, comment, or user.
  final String type;

  /// The admin's notes about the post/comment/user.
  /// This will only be shown to admins.
  final String? adminNotes;

  /// The admin's reason why the post/comment/user was deleted/block.
  /// This will show to the publc.
  final String? adminReason;

  @FirebaseDateTimeConverter()
  @JsonKey(includeFromJson: true, includeToJson: true)
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reason,
    this.resolved = false,
    this.uid,
    this.otherUid,
    this.postId,
    this.commentId,
    required this.type,
    this.adminNotes = '',
    this.adminReason = '',
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

  /// Used to delete the post/comment/user
  /// Note: these will be soft delete. Not actually deleted.
  Future<void> deleteContent(String reason, String adminNotes) async {
    if (type == 'comment') {
      final comment = await Comment.get(commentId!);
      await comment.delete(reason: reason);
      debugPrint("Deleting comment");
      toast(title: 'Deleted', message: 'Comment was deleted successfully');
      // TODO comment view delete
    } else if (type == 'post') {
      final post = await Post.get(postId!);
      final otherUser = await User.get(post.uid);
      post.delete(reason: reason, fromUids: otherUser!.followers);
      debugPrint("Deleting post");
      toast(title: 'Deleted', message: 'Post was deleted successfully');
      // TODO post view delete
    } else if (type == 'user') {
      // TODO user block/disable
      // await userDoc(id).delete();
    } else {
      // means the type is not handled yet
      toast(title: 'Error', message: 'Unknown Type: $type');
      return;
    }
    await markAsResove(adminNotes: adminNotes, adminReason: reason);
  }

  Future<void> markAsResove({String? adminNotes, String? adminReason}) async {
    await reportDoc(id).update({
      'resolved': true,
      'adminNotes': adminNotes ?? '',
      'adminReason': adminReason ?? '',
    });
  }
}
