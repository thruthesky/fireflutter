import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Post {
  /// Refs and Paths
  ///
  static const String node = 'posts';

  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();
  static DatabaseReference get postsRef => rootRef.child(node);
  static DatabaseReference categoryRef(String category) =>
      postsRef.child(category);

  /// Returns the reference of a post
  static DatabaseReference postRef(String category, String id) =>
      categoryRef(category).child(id);

  static DatabaseReference postSummariesRef = rootRef.child('post-summaries');

  /// Returns the reference of a post summary
  static DatabaseReference e(String category, String id) =>
      postSummariesRef.child(category).child(id);

  static DatabaseReference postAllSummariesRef =
      rootRef.child('post-all-summaries');

  /// Member variable reference
  DatabaseReference get noOfLikesRef => ref.child(Field.noOfLikes);
  DatabaseReference get urlsRef => ref.child(Field.urls);

  Post({
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
    required this.photoOrder,
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
  // this is ordering of post if the post have a photo included of the urls have values
  // photoOrder only exist if theres a urls
  final int? photoOrder;

  /// Get the category of the post
  String get category => ref.parent!.key!;

  /// Post's comments' database reference
  DatabaseReference get commentsRef => Comment.postComments(id);

  /// Take note of the category node. Check the snapshot ref parent
  /// because in `post-all-summaries`, category is part of the field.
  /// Since this model is shared by `post-all-summary` and `post-summary`,
  /// we need to check if category is included in the snapshot.
  factory Post.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot.exists == false) {
      throw FireFlutterException('Post.fromSnapshot/snapshot-not-exists',
          'Post.fromSnapshot: snapshot does not exist');
    }
    final value = snapshot.value as Map<dynamic, dynamic>;
    return Post.fromJson(
      value,
      id: snapshot.key!,
      category: value[Field.category] ?? snapshot.ref.parent!.key!,
    );
  }

  /// This is the factory constructor that takes a map and produces a Post
  ///
  /// ```dart
  /// final post = Post.fromJson(
  ///     {
  ///      ...data,
  ///      Field.createdAt: DateTime.now().millisecondsSinceEpoch,
  ///     Field.updatedAt: DateTime.now().millisecondsSinceEpoch,
  ///   },
  ///    id: ref.key!,
  ///  );
  /// ```
  ///
  /// Note, when creating from JSON data for testing and other purposes, values like uid, createdAt, etc. might be missing.
  /// Therefore, it provides default values.
  factory Post.fromJson(
    Map<dynamic, dynamic> json, {
    required String id,
    required String category,
  }) {
    if (category == '') {
      dog("id: $id, data: ${json.toString()}");
      throw FireFlutterException('Post.fromJson/category-is-empty',
          'Post.fromJson: category is empty');
    }
    return Post(
      id: id,
      ref: Post.postRef(category, id),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      uid: json['uid'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      order: json[Field.order] ?? 0,
      likes: List<String>.from((json['likes'] as Map? ?? {}).keys),
      noOfLikes: json[Field.noOfLikes] ?? 0,

      /// Post summary has the first photo url in 'url' field.
      urls: empty(json['url'])
          ? List<String>.from(json['urls'] ?? [])
          : [json['url']],
      noOfComments: json[Field.noOfComments] ?? 0,
      deleted: json[Field.deleted] ?? false,
      photoOrder: json['photoOrder'] ?? 0,
    );
  }

  /// Create a Post from a category with empty values.
  ///
  /// Use this factory to create a Post from a category with empty values.
  /// This is useful when you want to create a new post or using other post
  /// model properties or methods.
  ///
  /// It creates a reference with post id along with empty values. So, the post
  /// does not actaully exists in database, but you can use all the properties
  /// and method.
  ///
  /// ```dart
  /// final post = Post.fromCategory(category);
  /// ```
  ///
  factory Post.fromCategory(String category) {
    final ref = Post.categoryRef(category).push();
    return Post(
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
      photoOrder: null,
    );
  }

  @Deprecated(
      'summary is now updated automatically by cloud functoion. Do not use this method.')
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
    return 'Post(${toJson()})';
  }

  /// Reload the properties
  Future<Post> reload() async {
    final p = await Post.get(category: category, id: id);
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
  static Future<Post?> get(
      {required String category, required String id}) async {
    final snapshot = await Post.postRef(category, id).get();
    if (snapshot.exists) {
      return Post.fromSnapshot(snapshot);
    }
    return null;
  }

  /// Get a post from all summary.
  ///
  /// You can get category from the post id.
  static Future<Post?> getAllSummary(String id) async {
    final snapshot = await postAllSummariesRef.child(id).get();
    if (snapshot.exists) {
      return Post.fromSnapshot(snapshot);
    }
    return null;
  }

  /// Get the value of the field of a post
  static Future<dynamic> field(
      {required String category, required String id, required String field}) {
    return Post.postRef(category, id).child(field).get();
  }

  /// Create post data in the database
  ///
  /// Note that, post must be created with this method since it has some
  /// special logic only for creating post.
  ///
  /// /posts
  /// /posts-summary
  /// /posts-all
  static Future<Post?> create({
    required String title,
    required String content,
    required String category,
    List<String>? urls,
    String? group,
  }) async {
    if (iam.disabled) return null;

    if (ActionLogService.instance.postCreate[category] != null) {
      if (await ActionLogService.instance.postCreate[category]!.isOverLimit()) {
        return null;
      }
    }

    if (ActionLogService.instance.postCreate['all'] != null) {
      /// 만약 'all' 카테고리가 제한이 되었으면, 모든 게시판을 통틀어서 제한이 되었는지 확인한다.
      if (await ActionLogService.instance.postCreate['all']!.isOverLimit()) {
        return null;
      }
    }

    final order = DateTime.now().millisecondsSinceEpoch * -1;

    final data = {
      'uid': myUid,
      'title': title,
      'content': content,
      Field.urls: urls,
      'createdAt': ServerValue.timestamp,
      Field.order: order,
      if (group != null) 'group': group,
    };

    final DatabaseReference ref = Post.categoryRef(category).push();

    dog("Post.create: ref.key: ${ref.path}, data: $data");
    await ref.set(data);

    /// Read the post data from the database
    final snapshot = await ref.get();
    final created = Post.fromSnapshot(snapshot);

    ActionLog.postCreate(category: category, postId: created.id);
    ActivityLog.postCreate(category: category, postId: created.id);

    /// Call the onPostCreate callback
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
  Future<Post> update({
    String? title,
    String? content,
    List<String>? urls,
    int? order,
    bool? deleted,
    Map<String, dynamic>? otherData,
  }) async {
    final Map<String, Object?> data = {
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

  static Future<Post> _afterUpdate(DatabaseReference ref) async {
    final snapshot = await ref.get();
    final updated = Post.fromSnapshot(snapshot);

    ForumService.instance.onPostUpdate?.call(updated);
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
    final snapshot = await Comment.postComments(id).limitToFirst(1).get();
    final doesCommentsExist = snapshot.exists;
    if (doesCommentsExist) {
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
  Future<void> like({
    required BuildContext context,
  }) async {
    if (notLoggedIn) {
      final re = await UserService.instance.loginRequired!(
          context: context,
          action: 'post-like',
          data: {
            'post': this,
          });
      if (re != true) return;
    }

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
    return Value(
      ref: ref.child(field),
      builder: builder,
      onLoading: onLoading,
    );
  }

  /// /post-summary 에서 가장 최근 글 몇개를 가져온다.
  ///
  /// 예제는 PostLatestListView 를 참고한다.
  ///
  /// 중요: order 로 정렬하지 않고, createdAt 으로 정렬한다.
  static Future<List<Post>> latestSummary({
    String? category,
    String? group,
    int limit = 5,
  }) async {
    assert(category != null || group != null);
    Query ref;

    /// Get posts from /posts-summaries if [category] is given
    if (category != null) {
      ref = postSummariesRef.child(category).orderByChild(Field.createdAt);
    } else if (group != null) {
      /// Get posts from /posts-all-smmaries if [group] is given
      ref = postAllSummariesRef
          .orderByChild("group_order")
          .startAt(group)
          .endAt('$group\uf8ff');
    } else {
      throw 'category or group must be given';
    }

    // .orderByKey()
    final snapshot = await ref.limitToLast(limit).get();

    final List<Post> posts =
        (snapshot.exists == false || snapshot.value == null)
            ? []
            : snapshot.children.map((DataSnapshot e) {
                return Post.fromJson(
                  e.value as Map,
                  id: e.key as String,

                  /// posts from `/posts-all-summaries` has no input category. So, it gets from the data.
                  category: category ?? (e.value as Map)['category']!,
                );
              }).toList();

    return posts.reversed.toList();
  }
}
