import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/functions/comment_sort_string.dart';
import 'package:fireflutter/src/mixin/firebase_helper.mixin.dart';
import 'package:fireflutter/src/service/comment.service.dart';

class Comment with FirebaseHelper {
  final String id;
  final String postId;
  // TODO reply comment ID
  final String content;
  @override
  final String uid;
  final List<dynamic>? files;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<dynamic> likes;
  final bool? deleted;
  final String? replyTo;
  final String sort;
  final int depth;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.uid,
    this.files,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    this.deleted,
    this.replyTo,
    required this.sort,
    required this.depth,
  });

  factory Comment.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Comment.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Comment.fromMap({required Map<String, dynamic> map, required id}) {
    return Comment(
      id: id,
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      uid: map['uid'] ?? '',
      files: map['files'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      likes: map['likes'] ?? [],
      deleted: map['deleted'],
      replyTo: map['replyTo'],
      // TODO put the last sort here? so that the dirty records go down? or not?
      sort: map['sort'] ?? fillBlocksIfEmpty(blocks: sortBlocks),
      depth: map['depth'] ?? 0,
    );
  }

  static Future<Comment> create({
    required String postId,
    required String content,
    List<String>? files,
    String? replyTo,
    String? sort, // sort Of which comment to reply
    int depth = 0,
  }) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> commentData = {
      'content': content,
      'postId': postId,
      if (files != null) 'files': files,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'uid': myUid,
      if (replyTo != null) 'replyTo': replyTo,
      'sort': generateCommentSort(sortString: sort, depth: depth),
      'depth': depth,
    };
    final commentId = CommentService.instance.commentCol.doc().id;
    await CommentService.instance.commentCol.doc(commentId).set(commentData);
    commentData['createdAt'] = Timestamp.now();
    commentData['updatedAt'] = Timestamp.now();
    return Comment.fromMap(map: commentData, id: postId);
  }

  @override
  String toString() =>
      'Comment(id: $id, postId: $postId, content: $content, uid: $uid, files: $files, createdAt: $createdAt, updatedAt: $updatedAt, likes: $likes, deleted: $deleted, replyTo: $replyTo, sort: $sort, depth: $depth)';
}
