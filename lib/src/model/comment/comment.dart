import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/comment_sort_string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment with FirebaseHelper {
  static const String collectionName = 'comments';
  static DocumentReference doc([String? commentId]) =>
      CommentService.instance.commentCol.doc(commentId);

  final String id;
  final String postId;
  final String content;
  @override
  final String uid;
  final List<String> urls;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;
  final List<String> likes;
  final bool? deleted;

  /// Parent ID is the comment ID of the comment that this comment is replying to.
  /// It will be null if this comment is not a reply (or the first level of comment)
  final String? parentId;
  final String sort;
  final int depth;

  bool get iLiked => likes.contains(my.uid);
  String get noOfLikes => likes.isNotEmpty ? '(${likes.length})' : '';

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<String, dynamic> data;

  Comment({
    required this.id,
    required this.postId,
    this.content = '',
    required this.uid,
    this.urls = const [],
    dynamic createdAt,
    this.likes = const [],
    this.deleted = false,
    this.parentId,
    required this.sort,
    required this.depth,
  }) : createdAt =
            (createdAt is Timestamp) ? createdAt.toDate() : DateTime.now();

  factory Comment.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Comment.fromJson({
      ...documentSnapshot.data() as Map<String, dynamic>,
      ...{'id': documentSnapshot.id}
    });
  }

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  String toString() => '';
  // 'Comment(id: $id, postId: $postId, content: $content, uid: $uid, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, likes: $likes, deleted: $deleted, parentId: $parentId, sort: $sort, depth: $depth)';

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
      'sort': getCommentSortString(
          noOfComments: post.noOfComments,
          depth: parent?.depth ?? 0,
          sortString: parent?.sort),
      'depth': parent == null ? 1 : parent.depth + 1,
    };

    await CommentService.instance.commentCol.add(commentData);
    PostService.instance.postCol
        .doc(post.id)
        .update({'noOfComments': FieldValue.increment(1)});

    // update no of comments
    User.fromUid(UserService.instance.uid).update(
      noOfComments: FieldValue.increment(1),
    );

    //
    Category.fromId(post.categoryId).update(
      noOfComments: FieldValue.increment(1),
    );

    //
    return Comment.fromJson({
      ...commentData,
      ...{'id': post.id}
    });
  }

  static Future<Comment> get(String id) async {
    final DocumentSnapshot documentSnapshot =
        await CommentService.instance.commentCol.doc(id).get();
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

  /// Likes or Unlikes the comment
  ///
  /// If I already liked (iLiked == true)
  /// it will add my uid to the likes...
  /// otherwise, it will remove my uid from the likes.
  Future<void> likeOrUnlike() async {
    if (iLiked) {
      await CommentService.instance.commentCol.doc(id).update({
        'likes': FieldValue.arrayRemove([my.uid]),
      });
    } else {
      await CommentService.instance.commentCol.doc(id).update({
        'likes': FieldValue.arrayUnion([my.uid]),
      });
    }
  }

  /// Copy the properties of [map] into current Comment model and returns a new Comment model.
  ///
  copyWith(Map<String, dynamic> map) {
    return Comment.fromJson({
      ...toJson(),
      ...map,
    });
  }
}
