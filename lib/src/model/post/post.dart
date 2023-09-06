import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post with FirebaseHelper {
  static const String collectionName = 'posts';
  static DocumentReference doc([String? postId]) => PostService.instance.postCol.doc(postId);
  final String id;
  final String categoryId;
  final String title;
  final String content;

  final String youtubeId;

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic>? data;

  @override
  final String uid;

  final List<String> urls;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  final List<String> likes;
  final bool? deleted;
  final int noOfComments;

  bool get iLiked => likes.contains(my.uid);
  String get noOfLikes => likes.isNotEmpty ? '(${likes.length})' : '';

  Post({
    required this.id,
    this.categoryId = '',
    this.title = '',
    this.content = '',
    this.youtubeId = '',
    this.uid = '',
    this.urls = const [],
    createdAt,
    this.likes = const [],
    this.deleted = false,
    this.noOfComments = 0,
  }) : createdAt = (createdAt is Timestamp) ? createdAt.toDate() : DateTime.now();

  factory Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Post.fromJson(
      {
        ...documentSnapshot.data() as Map<String, dynamic>,
        ...{'id': documentSnapshot.id}
      },
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json)..data = json;
  Map<String, dynamic> toJson() => _$PostToJson(this);

  static Future<Post> get(String? id) async {
    if (id == null) {
      throw Exception('Post id is null');
    }
    final DocumentSnapshot documentSnapshot = await PostService.instance.postCol.doc(id).get();
    return Post.fromDocumentSnapshot(documentSnapshot);
  }

  static Future<Post> create({
    required String categoryId,
    required String title,
    required String content,
    String? youtubeId,
    List<String>? urls,
    Map<String, dynamic> data = const {},
  }) async {
    final Map<String, dynamic> postData = {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      if (youtubeId != null) 'youtubeId': youtubeId,
      if (urls != null) 'urls': urls,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': UserService.instance.uid,
      ...data,
    };
    final postId = Post.doc().id;
    await Post.doc(postId).set(postData);

    // update no of posts
    User.fromUid(FirebaseAuth.instance.currentUser!.uid).update(
      noOfPosts: FieldValue.increment(1),
    );
    Category.fromId(categoryId).update(
      noOfPosts: FieldValue.increment(1),
    );

    // create feed
    final post = Post.fromJson(
      {
        ...postData,
        ...{'id': postId},
      },
    );
    FeedService.instance.create(post: post);

    // return post
    return post;
  }

  Future<void> update({
    required String title,
    required String content,
    List<String>? urls,
  }) async {
    final Map<String, dynamic> postUpdateData = {
      'title': title,
      'content': content,
      if (urls != null) 'urls': urls,
      if (urls == null) 'urls': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await PostService.instance.postCol.doc(id).update(postUpdateData);
  }

  /// Likes or Unlikes the post
  ///
  /// If I already liked (iLiked == true)
  /// it will add my uid to the likes...
  /// otherwise, it will remove my uid from the likes.
  Future<void> like() async {
    if (iLiked) {
      await PostService.instance.postCol.doc(id).update({
        'likes': FieldValue.arrayRemove([my.uid]),
      });
    } else {
      await PostService.instance.postCol.doc(id).update({
        'likes': FieldValue.arrayUnion([my.uid]),
      });
    }
  }

  @override
  String toString() => 'Post(${toJson()})';
  bool get isMine {
    return UserService.instance.uid == uid;
  }
}
