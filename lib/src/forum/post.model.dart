import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostModel {
  PostModel({
    required this.ref,
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.uid,
    required this.createdAt,
    required this.order,
    required this.likes,
    required this.noOfLikes,
    required this.urls,
    required this.comments,
    required this.noOfComments,
    required this.deleted,
  });

  final DatabaseReference ref;
  final String id;
  String title;
  String content;
  final String category;
  final String uid;
  final DateTime createdAt;
  final int order;
  List<String>? likes;
  List<String>? urls;
  List<String>? comments;

  int noOfLikes;
  int noOfComments;

  bool deleted;

  factory PostModel.fromSnapshot(DataSnapshot snapshot) => PostModel.fromJson(
        snapshot.value as Map<dynamic, dynamic>,
        id: snapshot.key!,
      );

  /// This is the factory constructor that takes a map and produces a PostModel
  ///
  /// ```dart
  /// final post = PostModel.fromJson(
  ///     {
  ///      ...data,
  ///      Field.createdAt: DateTime.now().millisecondsSinceEpoch,
  ///     Field.updatedAt: DateTime.now().millisecondsSinceEpoch,
  ///   },
  ///    id: ref.key!,
  ///  );
  /// ```
  factory PostModel.fromJson(Map<dynamic, dynamic> json, {required String id}) => PostModel(
        id: id,
        ref: Ref.post(json['category'], id),
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        category: json['category'],
        uid: json['uid'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        order: json[Field.order],
        likes: List<String>.from((json['likes'] as Map? ?? {}).keys),
        noOfLikes: json[Field.noOfLikes] ?? 0,
        urls: List<String>.from(json['urls'] ?? []),
        comments: List<String>.from(json['comments'] ?? []),
        noOfComments: json[Field.noOfComments] ?? 0,
        deleted: json[Field.deleted] ?? false,
      );

  Map<String, dynamic> toSummary() => {
        Field.uid: uid,
        'id': id,
        'title': title.upTo(64),
        Field.content: content.upTo(128),
        'category': category,
        'createdAt': createdAt.millisecondsSinceEpoch,
        Field.order: order,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'uid': uid,
        'createdAt': createdAt,
        'likes': likes,
        'noOfLikes': noOfLikes,
        'urls': urls,
        'comments': comments,
        'noOfComments': noOfComments,
        'deleted': deleted,
      };

  @override
  String toString() {
    return 'PostModel(${toJson()})';
  }

  /// Reload the properties
  Future<PostModel> reload() async {
    final p = await PostModel.get(category: category, id: id);
    if (p != null) {
      title = p.title;
      content = p.content;
      likes = p.likes;
      noOfLikes = p.noOfLikes;
      urls = p.urls;
      comments = p.comments;
      noOfComments = p.noOfComments;
      deleted = p.deleted;
    }
    return this;
  }

  /// Get a post by id and category
  static Future<PostModel?> get({required String category, required String id}) async {
    final snapshot = await Ref.post(category, id).get();
    if (snapshot.exists) {
      return PostModel.fromSnapshot(snapshot);
    }
    return null;
  }

  /// Get the value of the field of a post
  static Future<dynamic> field(
      {required String category, required String id, required String field}) {
    return Ref.post(category, id).child(field).get();
  }

  /// Create post data in the database
  ///
  /// /posts
  /// /posts-summary
  /// /posts-all
  static Future<void> create({
    required String title,
    required String content,
    required String category,
  }) async {
    final data = {
      Field.category: category,
      'title': title,
      'content': content,
      'uid': myUid,
      'createdAt': ServerValue.timestamp,
      Field.order: DateTime.now().millisecondsSinceEpoch * -1,
    };

    final DatabaseReference ref = Ref.category(category).push();

    dog("PostModel.create: ref.key: ${ref.path}, data: $data");
    await ref.set(data);

    await _afterCreate(ref);
  }

  /// Create post data in the database
  static _afterCreate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final created = PostModel.fromSnapshot(snapshot);
    // don't wait for this
    created.update(order: -created.createdAt.millisecondsSinceEpoch);

    final data = created.toSummary();
    data[Field.order] = -created.createdAt.millisecondsSinceEpoch;

    await Ref.postSummary.child(created.category).child(created.id).set(created.toSummary());
  }

  Future<void> update({
    String? category,
    String? title,
    String? content,
    int? order,
    bool? deleted,
  }) async {
    final data = {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (order != null) Field.order: order,
      if (deleted != null) Field.deleted: deleted,
    };

    if (data.isEmpty) return;
    await ref.update(data);

    /// Don't wait for this
    _afterUpdate(ref);
  }

  static _afterUpdate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final updated = PostModel.fromSnapshot(snapshot);
    await Ref.postSummary.child(updated.category).child(updated.id).set(updated.toSummary());
  }

  /// Delete post
  ///
  /// If there is no comment, delete the post. Or update the title and content to 'deleted'.
  /// And set the deleted field to true.
  Future<void> delete() async {
    if (comments!.isEmpty) {
      await ref.remove();
    } else {
      await update(
        title: Code.deleted,
        content: Code.deleted,
        deleted: true,
      );
    }
    _afterDelete();
  }

  _afterDelete() async {
    if (comments!.isEmpty) {
      await Ref.postSummary.child(category).child(id).remove();
    } else {
      await Ref.postSummary.child(category).child(id).set({
        Field.title: Code.deleted,
        Field.content: Code.deleted,
        Field.deleted: true,
      });
    }
  }

  /// Like or unlike
  ///
  /// It loads all the likes and updates.
  Future<void> like() async {
    final snapshot = await ref.child(Field.likes).get();
    likes = List<String>.from((snapshot.value as Map? ?? {}).keys);

    if (likes?.contains(myUid) == false) {
      ref.child(Field.likes).child(myUid!).set(true);
      likes?.add(myUid!);
      ref.child(Field.noOfLikes).set(likes?.length ?? 0);
    } else {
      ref.child(Field.likes).child(myUid!).remove();
      likes?.remove(myUid);
      ref.child(Field.noOfLikes).set(likes?.length ?? 0);
    }
  }

  onFieldChange(String field, Widget Function(dynamic) builder) {
    return Database(
      path: ref.child(field).path,
      builder: builder,
    );
  }
}
