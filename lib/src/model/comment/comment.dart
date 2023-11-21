import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/comment_sort_string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  static const String collectionName = 'comments';
  static CollectionReference get col => commentCol;
  static DocumentReference doc([String? commentId]) => commentCol.doc(commentId);

  final String id;
  final String postId;
  final String content;
  final String uid;
  final List<String> urls;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  final List<String> likes;
  final bool deleted;
  final String? deletedReason;
  // final DateTime? deletedAt;

  /// Parent ID is the comment ID of the comment that this comment is replying to.
  /// It will be null if this comment is not a reply (or the first level of comment)
  final String? parentId;
  final String sort;
  final int depth;

  bool get iLiked => likes.contains(myUid);
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
    required this.createdAt,
    this.likes = const [],
    this.deleted = false,
    this.parentId,
    required this.sort,
    required this.depth,
    this.deletedReason,
    // this.deletedAt,
  });

  factory Comment.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Comment.fromJson({
      ...documentSnapshot.data() as Map<String, dynamic>,
      ...{'id': documentSnapshot.id}
    });
  }

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  @override
  String toString() => 'Comment( ${toJson()})';
  // 'Comment(id: $id, postId: $postId, content: $content, uid: $uid, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, likes: $likes, deleted: $deleted, parentId: $parentId, sort: $sort, depth: $depth)';

  /// Create a comment
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

    final ref = await col.add(commentData);

    postCol.doc(post.id).update({'noOfComments': FieldValue.increment(1)});

    // update no of comments of the user
    User.fromUid(myUid).update(
      noOfComments: FieldValue.increment(1),
    );

    // For some apps, they don't use category at all.
    if (post.categoryId.isNotEmpty) {
      Category.fromId(post.categoryId).update(
        noOfComments: FieldValue.increment(1),
      );
    }

    // Assemble the comment without getting from server since it takes time.
    final createdComment = Comment.fromJson({
      ...commentData,
      'id': ref.id,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    });

    // Invoite the callback for comment creation.
    CommentService.instance.onCreate?.call(createdComment);

    activityLogCommentCreate(postId: post.id, commentId: createdComment.id);

    return createdComment;
  }

  static Future<Comment> get(String id) async {
    final DocumentSnapshot documentSnapshot = await commentCol.doc(id).get();
    return Comment.fromDocumentSnapshot(documentSnapshot);
  }

  /// Update a comment
  ///
  /// This method is the only method to be used for updating a comment.
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
    final updatedComment = copyWith(commentData);

    // Invoite the callback for comment creation.
    CommentService.instance.onUpdate?.call(updatedComment);

    activityLogCommentUpdate(commentId: id, postId: postId);

    return updatedComment;
  }

  /// Delete a comment
  /// This is soft delete: Contents are removed. But the document is still there.
  Future<Comment> delete() async {
    // delete the comment's photos
    // no need to await
    for (var url in urls) {
      StorageService.instance.delete(url).catchError((e) => toast(title: 'Error', message: e.toString()));
    }
    final deletedCommentData = {
      'content': '',
      'urls': [],
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    };
    await commentCol.doc(id).update(deletedCommentData);
    final deletedComment = copyWith(deletedCommentData);

    /// log comment delete
    activityLogCommentDelete(commentId: id, postId: postId);
    return deletedComment;
  }

  /// This method must be the only method to like or unlike Comment. Don't it in
  /// another way.
  ///
  /// Likes or Unlikes the comment
  ///
  /// If I already liked (iLiked == true)
  /// it will add my uid to the likes...
  /// otherwise, it will remove my uid from the likes.
  Future<bool?> like() async {
    if (notLoggedIn) {
      toast(title: tr.loginFirstTitle, message: tr.loginFirstMessage);
      return null;
    }
    if (my!.isDisabled) {
      toast(title: tr.disabled, message: tr.disabledMessage);
      return null;
    }
    bool isLiked = await toggle(pathCommentLikedBy(id));

    /// call back when the comment is liked or unliked
    CommentService.instance.sendNotificationOnLike(this, isLiked);

    CommentService.instance.onLike?.call(this, isLiked);

    // log comment like/unlike
    activityLogCommentLike(commentId: id, isLiked: isLiked);

    return isLiked;
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
