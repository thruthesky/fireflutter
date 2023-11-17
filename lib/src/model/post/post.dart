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

  bool get iLiked => likes.contains(myUid);

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
    required this.createdAt,
    this.likes = const [],
    this.deleted = false,
    this.reason,
    this.noOfComments = 0,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    /// Save the list of uids who saw the post.
    if (PostService.instance.enableSeenBy && loggedIn) {
      set('posts/${documentSnapshot.id}/seenBy/$myUid', true);
    }

    return Post.fromJson(
      {
        ...documentSnapshot.data() as Map<String, dynamic>,
        'id': documentSnapshot.id,
        // Added this because DateTime converter still gives wrong date.
        // If document hasPendingWrites, the date becomes 'null' temporarily
        // thus, the converter gives DateTime(1970) instead of DateTime.now()
        // This is to display DateTime.now() to the user while post is still being saved.
        if (documentSnapshot.metadata.hasPendingWrites) 'createdAt': DateTime.now(),
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
  ///
  /// Removed async - need to review (-dev2)
  static Future<Post> create({
    String? categoryId,
    String? title,
    String? content,
    String? youtubeId,
    List<String>? urls,
    List<String>? hashtags,
    Map<String, dynamic> data = const {},
  }) {
    final Map<String, dynamic> postData = {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (categoryId != null) 'categoryId': categoryId,
      if (youtubeId != null) 'youtubeId': youtubeId,
      // We added Photo Grid View in Grc.
      // There is no way to query if array is empty in Firestore.
      // but we can check if it is null.
      // so, we will save empty array as null
      // so that we can query if post has photos or not.
      if (urls != null && urls.isNotEmpty) 'urls': urls,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': myUid!,
      if (hashtags != null) 'hashtags': hashtags,
      // I also want to see my own post in the feed, so I add myUid too.
      if (my!.followers.isNotEmpty) 'followers': [...my!.followers, myUid],
      ...data,
    };
    final postId = Post.doc().id;

    // Removed await -  need to review
    Post.doc(postId).set(postData);

    // Assemble the post without getting it from the server since it takes time.
    final post = Post.fromJson(
      {
        ...postData,
        'id': postId,
        'createdAt': DateTime.now(),
      },
    );
    dog(post.toString());
    PostService.instance.onCreate?.call(post);

    // update no of posts
    User.fromUid(FirebaseAuth.instance.currentUser!.uid).update(
      noOfPosts: FieldValue.increment(1),
    );
    if (categoryId != null && categoryId.isNotEmpty) {
      Category.fromId(categoryId).update(
        noOfPosts: FieldValue.increment(1),
      );
    }

    /// log post create
    activityLogPostCreate(postId: postId);

    // return post
    return Future.value(post);
  }

  /// Post udpate
  ///
  ///
  /// Returns a Future<Post>
  ///
  /// Note, it updates the [updatedAt] field automatically.
  /// For security reason, the admin and the author can only use this method.
  ///
  /// [log] is on by default. If you don't want to log, set it to false.
  Future<Post> update({
    String? title,
    String? content,
    List<String>? urls,
    String? youtubeId,
    List<String>? hashtags,
    bool? deleted,
    Map<String, dynamic> data = const {},
    bool log = true,
  }) async {
    final Map<String, dynamic> postUpdateData = {
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (urls != null) 'urls': urls,
      if (youtubeId != null) 'youtubeId': youtubeId,
      if (hashtags != null) 'hashtags': hashtags,
      if (deleted != null) 'deleted': deleted,
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

    /// log post update
    if (log) activityLogPostUpdate(postId: id);

    return updatedPost;
  }

  /// Update the list of followers
  ///
  /// For the security reason, it can't use the [update] method.
  Future updateFollowers(FieldValue followers) async {
    await postCol.doc(id).update({'followers': followers});
  }

  /// Delete the post.
  ///
  /// This method will delete the post, update the no of posts of the user and the category.
  /// It will also delete all the feeds of the post.
  Future<void> delete({String? deletedReason}) async {
    await update(
      title: '',
      content: '',
      urls: [],
      youtubeId: '',
      hashtags: [],
      deleted: true,
      data: {
        'deletedReason': deletedReason ?? 'Deleted',
      },
      log: false, // don't log for update.
    );

    /// log post delete
    activityLogPostDelete(postId: id);
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
    if (my!.isDisabled) {
      toast(title: tr.disabled, message: tr.disabledMessage);
      return null;
    }
    bool isLiked = await toggle(pathPostLikedBy(id));

    // call back when the post is liked or unliked
    PostService.instance.sendNotificationOnLike(this, isLiked);
    PostService.instance.onLike?.call(this, isLiked);

    /// log post like/unlike
    activityLogPostLike(postId: id, isLiked: isLiked);

    return isLiked;
  }

  @override
  String toString() => 'Post(${toJson()})';
  bool get isMine {
    return loggedIn && myUid! == uid;
  }
}
