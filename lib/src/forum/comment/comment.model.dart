import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class CommentModel {
  final DatabaseReference ref;
  final String id;
  final String? parentId;
  String content;
  final String uid;
  final int createdAt;
  List<String> urls = [];
  int depth;

  /// Category is added here since we cannot access post category using ref..parent..key
  String category;

  bool deleted;

  /// Get the post id of the comment.
  ///
  String get postId => ref.parent!.key!;

  List<String> likes;
  double get leftMargin {
    if (depth == 0) {
      return 0;
    } else if (depth == 1) {
      return 32;
    } else if (depth == 2) {
      return 48;
    } else if (depth == 3) {
      return 64;
    } else if (depth == 4) {
      return 80;
    } else if (depth == 5) {
      return 90;
    } else if (depth == 6) {
      return 100;
    } else {
      return 108;
    }
  }

  CommentModel({
    required this.ref,
    required this.id,
    required this.parentId,
    required this.content,
    required this.uid,
    required this.createdAt,
    required this.urls,
    this.depth = 0,
    this.likes = const [],
    this.category = '',
    this.deleted = false,
  });

  factory CommentModel.fromSnapshot(DataSnapshot snapshot) {
    return CommentModel.fromMap(
      snapshot.value as Map,
      snapshot.key!,
      // category: snapshot.ref.parent!.parent!.parent!.key!,
      postId: snapshot.ref.parent!.key!,
    );
  }

  factory CommentModel.fromMap(
    Map<dynamic, dynamic> map,
    String id, {
    // required String category,
    required String postId,
  }) {
    return CommentModel(
      ref: Ref.postComment(postId, id),
      id: id,
      parentId: map['parentId'],
      content: map['content'],
      uid: map['uid'],
      createdAt: map['createdAt'],
      urls: List<String>.from(map['urls'] ?? []),
      likes: List<String>.from((map['likes'] as Map? ?? {}).keys),
      // Category is added since we cannot access post category using ref..parent..key
      category: map['category'] ?? '',
      depth: map['depth'] ?? 0,
      deleted: map['deleted'] ?? false,
    );
  }

  /// Create a CommentModel from a post with empty values.
  ///
  /// Use this factory to create a CommentModel from a post with empty values.
  /// This is useful to create a new comment or to use other comment model
  /// properties or methods.
  ///
  /// It creates a comment reference with the give post's category and id
  /// along with empty values. So, the comment does not actaully exists in
  /// database, but you can use all the properties and method.
  ///
  /// ```dart
  /// final post = CommentModel.fromPost(post);
  /// ```
  ///
  factory CommentModel.fromPost(PostModel post) {
    final fakeRef = Ref.postComments(post.id).push();
    return CommentModel(
      ref: fakeRef,
      id: fakeRef.key!,
      parentId: null,
      content: '',
      category: post.category,
      uid: myUid!,
      createdAt: 0,
      urls: [],
      likes: [],
    );
  }

  /// Create a CommentModel from a parent comment with empty values.
  factory CommentModel.fromParent(CommentModel parent) {
    final fakeRef = parent.ref.parent!.push();
    return CommentModel(
      ref: fakeRef,
      id: fakeRef.key!,
      parentId: parent.ref.key,
      content: '',
      uid: myUid!,
      createdAt: 0,
      urls: [],
      likes: [],
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'id': id,
        'parentId': parentId,
        'uid': uid,
        'createdAt': createdAt,
        'urls': urls,
        'likes': likes,
        'deleted': deleted,
      };

  @override
  String toString() {
    return 'CommentModel(ref: $ref, id: $id, parentId: $parentId, content: $content, uid: $uid, createdAt: $createdAt, urls: $urls, likes: $likes, deleted: $deleted)';
  }

  /// Get a comment from the database
  static Future<CommentModel> get({
    // required String category,
    required String postId,
    required String commentId,
  }) async {
    final snapshot = await Ref.comments.child(postId).child(commentId).get();
    return CommentModel.fromSnapshot(snapshot);
  }

  /// Get all the comments of a post
  ///
  ///
  static Future<List<CommentModel>> getAll({
    required String postId,
  }) async {
    print(Ref.comments.child(postId).path);
    final snapshot = await Ref.comments.child(postId).get();
    final comments = <CommentModel>[];
    if (snapshot.value == null) {
      return comments;
    }
    (snapshot.value as Map).forEach((key, value) {
      final comment = CommentModel.fromMap(
        value,
        key,
        postId: postId,
      );
      comments.add(comment);
    });

    return sortComments(comments);
  }

  /// Get the comments of the post
  static List<CommentModel> sortComments(List<CommentModel> comments) {
    /// Sort comments by createdAt
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final List<CommentModel> newComments = [];

    /// This is the list of comments that are not replies.
    /// It is sorted by createdAt.
    /// If the comment is a reply, it has the parentId of the parent comment.
    /// So, we can find the parent comment by searching the list.
    /// And add the reply to the parent comment's replies.
    for (final comment in comments) {
      if (comment.parentId == null) {
        newComments.add(comment);
      } else {
        /// 부모 찾기
        final index = newComments.indexWhere((e) => e.id == comment.parentId);

        comment.depth = newComments[index].depth + 1;

        /// 형제 찾기
        final siblingIndex =
            newComments.lastIndexWhere((e) => e.parentId == comment.parentId);
        if (siblingIndex == -1) {
          newComments.insert(index + 1, comment);
        } else {
          newComments.insert(siblingIndex + 1, comment);
        }
      }
    }

    return newComments;
  }

  /// Create a comment
  ///
  /// It's the instance member method. Not a static method.
  ///
  /// Note that, this is NOT a static method. It is an instance method that
  /// uses the properties of current instance.
  ///
  /// To create a comment, you need to create a comment model instance from
  /// the post model instance or parent comment model instance.
  ///
  /// ```dart
  /// final comment = CommentModel.fromPost(post);
  /// await comment.create(content: 'content');
  /// ```
  Future create({
    required String content,
    required String category,
    CommentModel? parent,
    List<String>? urls,
  }) async {
    Map<String, dynamic> data = {
      'content': content,
      'parentId': parent?.id,
      'category': category,
      // 'depth': parent?.depth ?? 0,
      'uid': myUid!,
      'createdAt': ServerValue.timestamp,
      'urls': urls,
    };

    print("ref: ${ref.path}, data: $data");

    await ref.set(data);

    final summaryRef = Ref.postSummary(category, postId);
    summaryRef.child(Field.noOfComments).set(ServerValue.increment(1));

    /// Don't wait for calling onCommentCreate.
    await CommentModel.get(
      // category: category,
      postId: postId,
      commentId: id,
    ).then((comment) {
      ForumService.instance.onCommentCreate?.call(comment);
    });
  }

  Future update({
    required String content,
    List<String>? urls,
    bool? deleted,
  }) async {
    await ref.update({
      'content': content,
      'urls': urls,
      if (deleted != null) 'deleted': deleted,
    });

    /// Update the current content of the comment.
    this.content = content;

    ForumService.instance.onCommentUpdate?.call(this);
  }

  /// Like or unlike
  ///
  /// It loads all the likes and updates.
  Future<void> like() async {
    final snapshot = await ref.child(Field.likes).get();
    likes = List<String>.from((snapshot.value as Map? ?? {}).keys);

    if (likes.contains(myUid) == false) {
      ref.child(Field.likes).child(myUid!).set(true);
      likes.add(myUid!);
    } else {
      ref.child(Field.likes).child(myUid!).remove();
      likes.remove(myUid);
    }
  }

  /// Delete post
  ///
  /// If there is no comment, delete the post. Or update the title and content to 'deleted'.
  /// And set the deleted field to true.
  Future<void> delete() async {
    await update(
      content: Code.deleted,
      deleted: true,
    );
    deleted = true;
    ForumService.instance.onCommentDelete?.call(this);
  }

  onFieldChange(
    String field,
    Widget Function(dynamic) builder, {
    Widget? onLoading,
  }) {
    return Database(
      path: ref.child(field).path,
      builder: builder,
      onLoading: onLoading,
    );
  }
}
