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
  });

  factory CommentModel.fromMap(
    Map<dynamic, dynamic> map,
    String id, {
    required String category,
    required String postId,
  }) {
    return CommentModel(
      ref: Ref.comment(category, postId, id),
      id: id,
      parentId: map['parentId'],
      content: map['content'],
      uid: map['uid'],
      createdAt: map['createdAt'],
      urls: List<String>.from(map['urls'] ?? []),
      likes: List<String>.from((map['likes'] as Map? ?? {}).keys),
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
    final fakeRef = Ref.comments(post.category, post.id).push();
    return CommentModel(
      ref: fakeRef,
      id: fakeRef.key!,
      parentId: null,
      content: '',
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
      };

  @override
  String toString() {
    return 'CommentModel(ref: $ref, id: $id, parentId: $parentId, content: $content, uid: $uid, createdAt: $createdAt, urls: $urls, likes: $likes)';
  }

  /// Create a comment from current comment instance.
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
    CommentModel? parent,
    List<String>? urls,
  }) async {
    final comment = CommentModel(
      ref: ref,
      id: ref.key!,
      parentId: parent?.ref.key,
      content: content,
      uid: myUid!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      urls: urls ?? [],
    );

    await ref.set(comment.toJson());

    final summaryRef = Ref.postSummary(ref.parent!.parent!.parent!.key!, ref.parent!.parent!.key!);
    summaryRef.child(Field.noOfComments).set(ServerValue.increment(1));

    ForumService.instance.onCommentCreate?.call(comment);
  }

  Future update({
    required String content,
    List<String>? urls,
  }) async {
    await ref.update({
      'content': content,
      'urls': urls,
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
    );

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
