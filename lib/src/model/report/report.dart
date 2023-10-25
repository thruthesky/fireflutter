import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> data = {};
  final String id;

  // for post [title] is the post title.
  // for comment [title] is the comment content.
  // for user [title] is the user name.
  final String title;

  /// the photo url of the post/comment/user that was reported.
  final String photoUrl;

  /// the name of the user whose post/comment/profile that was reported.
  final String name;

  /// Save the list of uid who reported.
  final List<String> reporters;

  /// the id of the post/comment/user that was reported.
  final String? otherUid, postId, commentId;

  /// The type of the report. Can be post, comment, or user.
  final String type;

  final Map<String, String> reportedBy;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  Report({
    required this.id,
    this.reporters = const [],
    this.otherUid,
    this.postId,
    this.commentId,
    required this.type,
    this.reportedBy = const {},
    required this.createdAt,
    this.title = '',
    this.photoUrl = '',
    this.name = '',
  });

  factory Report.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Report.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json)..data = json;

  Map<String, dynamic> toJson() => _$ReportToJson(this);

  @override
  toString() => "Report(${toJson().toString()})";

  static ({String id, String type}) info({
    String? otherUid,
    String? postId,
    String? commentId,
  }) {
    assert(postId != null || commentId != null || otherUid != null);
    String id = postId ?? commentId ?? otherUid!;

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
    // For review
    // Github Issue
    // https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=42599640
    // Upon reporting report stops at await reportDoc(id).get()
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

    final data = <String, dynamic>{
      'type': info.type,
      'createdAt': FieldValue.serverTimestamp(),
      myUid!: reason,
      'reporters': FieldValue.arrayUnion([myUid]),
    };
    if (postId != null) {
      data['postId'] = postId;
    } else if (commentId != null) {
      data['commentId'] = commentId;
    } else if (otherUid != null) {
      data['otherUid'] = otherUid;
    }

    // print('data; $data');

    await reportDoc(info.id).set(data, SetOptions(merge: true));
    return info.id;
  }

  /// Used to delete the post/comment/user
  /// Note: these will be soft delete. Not actually deleted.
  Future<void> deleteContent() async {
    if (type == 'comment') {
      final comment = await Comment.get(commentId!);
      await comment.delete();
      debugPrint("Deleting comment");
      toast(title: 'Deleted', message: 'Comment was deleted successfully');
    } else if (type == 'post') {
      final post = await Post.get(postId!);
      post.delete();
      debugPrint("Deleting post");
      toast(title: 'Deleted', message: 'Post was deleted successfully');
    } else if (type == 'user') {
      // github task https://github.com/users/thruthesky/projects/9/views/29?pane=issue&itemId=40666380
      // await userDoc(id).delete();
    } else {
      // means the type is not handled yet
      toast(title: 'Error', message: 'Unknown Type: $type');
      return;
    }
    await markAsResove();
  }

  Future<void> markAsResove() async {
    await reportDoc(id).delete();
  }
}
