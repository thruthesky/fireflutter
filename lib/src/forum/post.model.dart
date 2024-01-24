import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class PostModel {
  PostModel({
    required this.ref,
    required this.id,
    required this.title,
    required this.content,
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
  final String uid;
  final DateTime createdAt;
  final int order;
  List<String> likes;
  List<String> urls;
  List<CommentModel> comments;

  int noOfLikes;

  /// The number of comments
  ///
  /// This is save only under '/posts-summary'. This is not saved under '/posts'.
  int noOfComments;

  bool deleted;

  /// Get the category of the post
  String get category => ref.parent!.key!;

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
  factory PostModel.fromJson(Map<dynamic, dynamic> json, {required String id}) {
    return PostModel(
      id: id,
      ref: Ref.post(json['category'], id),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      uid: json['uid'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      order: json[Field.order] ?? 0,
      likes: List<String>.from((json['likes'] as Map? ?? {}).keys),
      noOfLikes: json[Field.noOfLikes] ?? 0,
      urls: List<String>.from(json['urls'] ?? []),
      comments: sortComments(
        Map<Object, Object>.from((json['comments'] ?? {}))
            .entries
            .map((e) => CommentModel.fromMap(
                  e.value as Map,
                  e.key as String,
                  category: json['category'],
                  postId: id,
                ))
            .toList(),
      ),
      noOfComments: json[Field.noOfComments] ?? 0,
      deleted: json[Field.deleted] ?? false,
    );
  }

  static List<CommentModel> sortComments(List<CommentModel> comments) {
    // final parents = comments.where((e) => e.parentId == null).toList();
    // parents.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // return parents;

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

  /// Create a PostModel from a category with empty values.
  ///
  /// Use this factory to create a PostModel from a category with empty values.
  /// This is useful when you want to create a new post or using other post
  /// model properties or methods.
  ///
  /// It creates a reference with post id along with empty values. So, the post
  /// does not actaully exists in database, but you can use all the properties
  /// and method.
  ///
  /// ```dart
  /// final post = PostModel.fromCategory(category);
  /// ```
  ///
  factory PostModel.fromCategory(String category) {
    final ref = Ref.category(category).push();
    return PostModel(
      id: ref.key!,
      ref: ref,
      title: '',
      content: '',
      uid: myUid!,
      createdAt: DateTime.now(),
      order: DateTime.now().millisecondsSinceEpoch * -1,
      likes: [],
      noOfLikes: 0,
      urls: [],
      comments: [],
      noOfComments: 0,
      deleted: false,
    );
  }

  Map<String, dynamic> toSummary() => {
        'category': category,
        Field.content: content.upTo(128),
        'createdAt': createdAt.millisecondsSinceEpoch,
        'id': id,
        Field.order: order,
        'title': title.upTo(64),
        Field.uid: uid,
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
  static Future<PostModel?> get(
      {required String category, required String id}) async {
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
  /// Note that, post must be created with this method since it has some
  /// special logic only for creating post.
  ///
  /// /posts
  /// /posts-summary
  /// /posts-all
  static Future<void> create({
    required String title,
    required String content,
    required String category,
    List<String>? urls,
  }) async {
    final data = {
      'uid': myUid,
      'title': title,
      'content': content,
      Field.urls: urls,
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

    await Ref.postSummary(created.category, created.id)
        .set(created.toSummary());

    ForumService.instance.onPostCreate?.call(created);
  }

  Future<void> update({
    String? category,
    String? title,
    String? content,
    List<String>? urls,
    int? order,
    bool? deleted,
  }) async {
    final data = {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (order != null) Field.order: order,
      if (deleted != null) Field.deleted: deleted,
      if (urls != null) Field.urls: urls,
    };

    if (data.isEmpty) return;
    await ref.update(data);

    /// Don't wait for this
    _afterUpdate(ref);
  }

  static _afterUpdate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final updated = PostModel.fromSnapshot(snapshot);
    await Ref.postSummary(updated.category, updated.id)
        .set(updated.toSummary());

    ForumService.instance.onPostCreate?.call(updated);
  }

  /// Delete post
  ///
  /// If there is no comment, delete the post. Or update the title and content to 'deleted'.
  /// And set the deleted field to true.
  Future<void> delete() async {
    if (comments.isEmpty) {
      await ref.remove();
    } else {
      await update(
        title: Code.deleted,
        content: Code.deleted,
        deleted: true,
      );
    }
    deleted = true;
    _afterDelete();
  }

  _afterDelete() async {
    if (comments.isEmpty) {
      await Ref.postSummary(category, id).remove();
    } else {
      await Ref.postSummary(category, id).set({
        Field.title: Code.deleted,
        Field.content: Code.deleted,
        Field.deleted: true,
      });
    }
    ForumService.instance.onPostDelete?.call(this);
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
      ref.child(Field.noOfLikes).set(likes.length);
    } else {
      ref.child(Field.likes).child(myUid!).remove();
      likes.remove(myUid);
      ref.child(Field.noOfLikes).set(likes.length);
    }
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
