import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  static const String collectionName = 'posts';
  static DocumentReference doc([String? postId]) => postCol.doc(postId);
  final String id;
  final String categoryId;
  final String title;
  final String content;

  final String youtubeId;

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? data;

  final String uid;

  final List<String> hashtags;

  final List<String> urls;
  bool get hasPhoto => urls.isNotEmpty;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  final List<String> likes;
  final bool? deleted;
  final String? reason;
  final int noOfComments;

  bool get iLiked => likes.contains(my.uid);

  @Deprecated('Do not use this')
  String get noOfLikes => likes.isNotEmpty ? '(${likes.length})' : '';

  Post({
    required this.id,
    this.categoryId = '',
    this.title = '',
    this.content = '',
    this.youtubeId = '',
    this.uid = '',
    this.hashtags = const [],
    this.urls = const [],
    createdAt,
    this.likes = const [],
    this.deleted = false,
    this.reason,
    this.noOfComments = 0,
  }) : createdAt = (createdAt is Timestamp) ? createdAt.toDate() : DateTime.now();

  factory Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    /// Save the list of uids who saw the post.
    if (PostService.instance.enableSeenBy && loggedIn) {
      set('posts/${documentSnapshot.id}/seenBy/$myUid', true);
    }

    return Post.fromJson(
      {
        ...documentSnapshot.data() as Map<String, dynamic>,
        ...{'id': documentSnapshot.id}
      },
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$PostToJson(this);

  /// If the post is not found, it throws an Exception.
  static Future<Post> get(String? id) async {
    if (id == null) {
      throw Exception('Post id is null');
    }
    final DocumentSnapshot documentSnapshot = await postCol.doc(id).get();
    if (documentSnapshot.exists == false) throw Exception('Post not found');
    return Post.fromDocumentSnapshot(documentSnapshot);
  }

  /// Get post via url
  /// If the post is not found, it throws an Exception.
  static Future<Post> getByUrl(String? url) async {
    if (url == null) {
      throw Exception('Post id is null');
    }
    final QuerySnapshot documentSnapshot = await postCol.where('urls', arrayContains: url).get();

    if (documentSnapshot.docs.isEmpty) throw Exception('Post not found');

    return Post.fromDocumentSnapshot(documentSnapshot.docs.first);
  }

  /// Create a post
  ///
  /// All the post must be created by this method.
  ///
  /// This method will create a post, update the no of posts of the user and the category.
  static Future<Post> create({
    required String categoryId,
    required String title,
    required String content,
    String? youtubeId,
    List<String>? urls,
    List<String>? hashtags,
    Map<String, dynamic> data = const {},
  }) async {
    final Map<String, dynamic> postData = {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      if (youtubeId != null) 'youtubeId': youtubeId,
      if (urls != null) 'urls': urls,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': myUid!,
      if (hashtags != null) 'hashtags': hashtags,
      ...data,
    };
    final postId = Post.doc().id;
    await Post.doc(postId).set(postData);

    // Assemble the post without getting it from the server since it takes time.
    final post = Post.fromJson(
      {
        ...postData,
        'id': postId,
        'createdAt': DateTime.now(),
      },
    );

    PostService.instance.onCreate?.call(post);

    // update no of posts
    User.fromUid(FirebaseAuth.instance.currentUser!.uid).update(
      noOfPosts: FieldValue.increment(1),
    );
    if (categoryId.isNotEmpty) {
      Category.fromId(categoryId).update(
        noOfPosts: FieldValue.increment(1),
      );
    }

    FeedService.instance.create(post: post);

    // return post
    return post;
  }

  /// Post udpate
  ///
  ///
  /// Returns a Future<Post>
  Future<Post> update({
    required String title,
    required String content,
    List<String>? urls,
    String? youtubeId,
    List<String>? hashtags,
    Map<String, dynamic> data = const {},
  }) async {
    final Map<String, dynamic> postUpdateData = {
      'title': title,
      'content': content,
      if (urls != null) 'urls': urls,
      if (youtubeId != null) 'youtubeId': youtubeId,
      if (hashtags != null) 'hashtags': hashtags,
      'updatedAt': FieldValue.serverTimestamp(),
      ...data,
    };
    await postCol.doc(id).update(postUpdateData);

    /// Assemble the updated post without getting it from the server since it takes time.
    final updatedPost = Post.fromJson(
      {
        ...toJson(),
        ...postUpdateData,
        'updatedAt': DateTime.now(),
      },
    );

    PostService.instance.onUpdate?.call(updatedPost);

    FeedService.instance.update(post: updatedPost);

    return updatedPost;
  }

  /// Delete the post.
  ///
  /// This method will delete the post, update the no of posts of the user and the category.
  /// It will also delete all the feeds of the post.
  Future<void> delete({String? reason, List<String>? fromUids}) async {
    await FeedService.instance.delete(post: this, fromUids: fromUids);
    await update(
      title: '',
      content: '',
      urls: [],
      youtubeId: '',
      hashtags: [],
      data: {
        'deleted': true,
        'reason': reason ?? 'Deleted',
      },
    );
  }

  /// Like or unline the post
  ///
  /// ! This method must be the only method to like or unlike. Don't it in another way.
  ///
  /// This method do extra works that are necessary for like and unlike.
  ///
  /// Returns true on like and false on unlike. It returns null if the user
  /// didn't logged int.
  ///
  Future<bool?> like() async {
    if (notLoggedIn) {
      toast(title: tr.loginFirstTitle, message: tr.loginFirstMessage);
      return null;
    }
    bool isLiked = await toggle(pathPostLikedBy(id));

    // call back when the post is liked or unliked
    PostService.instance.sendNotificationOnLike(this, isLiked);
    PostService.instance.onLike?.call(this, isLiked);

    return isLiked;
  }

  @override
  String toString() => 'Post(${toJson()})';
  bool get isMine {
    return loggedIn && myUid! == uid;
  }
}
