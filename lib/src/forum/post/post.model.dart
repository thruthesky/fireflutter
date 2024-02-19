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
    // required this.comments,
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

  int noOfLikes;

  /// The number of comments
  ///
  /// This is save only under '/posts-summary'. This is not saved under '/posts'.
  int noOfComments;

  bool deleted;

  /// Get the category of the post
  String get category => ref.parent!.key!;

  /// Post's comments' database reference
  DatabaseReference get commentsRef => Ref.postComments(id);

  /// Take note of the category node. Check the snapshot ref parent
  /// because in `post-all-summaries`, category is part of the field.
  /// Since this model is shared by `post-all-summary` and `post-summary`,
  /// we need to check if category is included in the snapshot.
  factory PostModel.fromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value as Map<dynamic, dynamic>;
    return PostModel.fromJson(
      value,
      id: snapshot.key!,
      category: value[Field.category] ?? snapshot.ref.parent!.key!,
    );
  }

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
  factory PostModel.fromJson(
    Map<dynamic, dynamic> json, {
    required String id,
    required String category,
  }) {
    return PostModel(
      id: id,
      ref: Ref.post(category, id),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      uid: json['uid'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      order: json[Field.order] ?? 0,
      likes: List<String>.from((json['likes'] as Map? ?? {}).keys),
      noOfLikes: json[Field.noOfLikes] ?? 0,

      /// Post summary has the first photo url in 'url' field.
      urls: empty(json['url'])
          ? List<String>.from(json['urls'] ?? [])
          : [json['url']],
      noOfComments: json[Field.noOfComments] ?? 0,
      deleted: json[Field.deleted] ?? false,
    );
  }

  static List<CommentModel> sortComments(List<DataSnapshot> commentSnapshots) {
    final comments =
        commentSnapshots.map((e) => CommentModel.fromSnapshot(e)).toList();

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
      // comments: [],
      noOfComments: 0,
      deleted: false,
    );
  }

  @Deprecated('summary is now updated automatically by cloud functoion')
  Map<String, dynamic> toSummary() => {
        Field.content: content.upTo(128),
        'createdAt': createdAt.millisecondsSinceEpoch,
        Field.order: order,
        'title': title.upTo(64),
        Field.uid: uid,
        'url': urls.firstOrNull,
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
        // 'comments': comments,
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
      // comments = p.comments;
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
  static Future<PostModel> create({
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

    return await _afterCreate(ref);
  }

  /// Create post data in the database
  static Future<PostModel> _afterCreate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final created = PostModel.fromSnapshot(snapshot);

    ForumService.instance.onPostCreate?.call(created);
    return created;
  }

  /// Update post data in the database
  ///
  /// For deleting the field, must use otherData
  /// instead of setting the arguments to null.
  /// Example:
  /// ```dart
  /// await post.update(
  ///   otherData: {
  ///     Field.title: null,
  ///   },
  /// );
  Future<PostModel> update({
    String? category,
    String? title,
    String? content,
    List<String>? urls,
    int? order,
    bool? deleted,
    Map<String, dynamic>? otherData,
  }) async {
    final data = {
      if (otherData != null) ...otherData,
      if (title != null) Field.title: title,
      if (content != null) Field.content: content,
      if (order != null) Field.order: order,
      if (deleted != null) Field.deleted: deleted,
      if (urls != null) Field.urls: urls,
    };

    if (data.isEmpty) return this;
    await ref.update(data);

    /// Don't wait for this
    return _afterUpdate(ref);
  }

  static Future<PostModel> _afterUpdate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final updated = PostModel.fromSnapshot(snapshot);

    ForumService.instance.onPostCreate?.call(updated);
    return updated;
  }

  /// Delete post
  ///
  /// If there is no comment, delete the post. Or update the title and content to 'deleted'.
  /// And set the deleted field to true.
  Future<void> delete() async {
    // PLEASE REVIEW: Updated this since comment node is updated.
    //                Checking if at least one comment exists.
    //                If not, delete the post.
    // QUESTION: Do we need to retrieve comments from RTDB
    //           to check if there are comments?
    final snapshot = await Ref.postComments(id).limitToFirst(1).get();
    dog("Post Id: $id");
    dog("Comment exists: ${snapshot.exists}");
    final doesCommentsExist = snapshot.exists;
    if (doesCommentsExist) {
      dog("Ref path: ${ref.path}");
      // await update(
      //   title: null,
      //   content: null,
      //   urls: null,
      //   deleted: true,
      // );
      await update(
        otherData: {
          Field.title: null,
          Field.content: null,
          Field.urls: null,
        },
      );
      await update(deleted: true);
    } else {
      await ref.remove();
    }
    deleted = true;
    _afterDelete();
  }

  _afterDelete() async {
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
