import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/comment_sort_string.dart';

class Comment with FirebaseHelper {
  final String id;
  final String postId;
  final String content;
  @override
  final String uid;
  final List<String> urls;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> likes;
  final bool? deleted;

  /// Parent ID is the comment ID of the comment that this comment is replying to.
  /// It will be null if this comment is not a reply (or the first level of comment)
  final String? parentId;
  final String sort;
  final int depth;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.uid,
    required this.urls,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    this.deleted,
    this.parentId,
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
      urls: List<String>.from(map['urls'] ?? []),
      createdAt: (map['createdAt'] is Timestamp) ? map['createdAt'] : Timestamp.now(),
      updatedAt: (map['updatedAt'] is Timestamp) ? map['updatedAt'] : Timestamp.now(),
      likes: List<String>.from(map['likes'] ?? []),
      deleted: map['deleted'],
      parentId: map['parentId'],
      sort: map['sort'],
      depth: map['depth'] ?? 0,
    );
  }

  @override
  String toString() =>
      'Comment(id: $id, postId: $postId, content: $content, uid: $uid, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, likes: $likes, deleted: $deleted, parentId: $parentId, sort: $sort, depth: $depth)';

  static Future<Comment> create({
    required Post post,
    Comment? parent,
    required String content,
    List<String>? urls,
  }) async {
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    final Map<String, dynamic> commentData = {
      'content': content,
      'postId': post.id,
      if (urls != null) 'urls': urls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'uid': myUid,
      if (parent != null) 'parentId': parent.id,
      'sort':
          getCommentSortString(noOfComments: post.noOfComments, depth: parent?.depth ?? 0, sortString: parent?.sort),
      'depth': parent == null ? 1 : parent.depth + 1,
    };

    await CommentService.instance.commentCol.add(commentData);
    PostService.instance.postCol.doc(post.id).update({'noOfComments': FieldValue.increment(1)});

    return Comment.fromMap(map: commentData, id: post.id);
  }

  static Future<Comment> get(String id) async {
    final DocumentSnapshot documentSnapshot = await CommentService.instance.commentCol.doc(id).get();
    return Comment.fromDocumentSnapshot(documentSnapshot);
  }

  Future<Comment> update({
    required String content,
    List<String>? urls,
  }) async {
    final Map<String, dynamic> commentData = {
      'content': content,
      if (urls != null) 'urls': urls,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await commentCol.doc(id).update(commentData);
    return copyWith(commentData);
  }

  /// Copy the properties of [map] into current Comment model and returns a new Comment model.
  ///
  copyWith(Map<String, dynamic> map) {
    return Comment(
      id: id,
      postId: postId,
      content: map['content'] ?? content,
      uid: uid,
      urls: map['urls'] ?? urls,
      createdAt: createdAt,
      updatedAt:
          map['updatedAt'] == null ? updatedAt : ((map['updatedAt'] is Timestamp) ? map['updatedAt'] : Timestamp.now()),
      likes: map['likes'] ?? likes,
      deleted: map['deleted'] ?? deleted,
      parentId: map['parentId'] ?? parentId,
      sort: map['sort'] ?? sort,
      depth: map['depth'] ?? depth,
    );
  }
}
