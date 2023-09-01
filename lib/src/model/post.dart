import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Post with FirebaseHelper {
  final String id;
  final String categoryId;
  final String title;
  final String content;

  @override
  final String uid;
  final List<String> urls;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<String> likes;
  final bool? deleted;
  final int noOfComments;

  Post({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.uid,
    required this.urls,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    this.deleted,
    required this.noOfComments,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Post.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Post.fromMap({required Map<String, dynamic> map, required id}) {
    return Post(
      id: id,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      uid: map['uid'] ?? '',
      urls: List<String>.from(map['urls'] ?? []),
      createdAt: (map['createdAt'] is Timestamp) ? map['createdAt'] : Timestamp.now(),
      updatedAt: (map['updatedAt'] is Timestamp) ? map['updatedAt'] : Timestamp.now(),
      likes: map['likes'] ?? [],
      deleted: map['deleted'],
      noOfComments: map['noOfComments'] ?? 0,
    );
  }

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
    List<String>? urls,
  }) async {
    final Map<String, dynamic> postData = {
      'title': title,
      'content': content,
      'categoryId': categoryId,
      if (urls != null) 'urls': urls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'uid': UserService.instance.uid,
    };
    final postId = PostService.instance.postCol.doc().id;
    await PostService.instance.postCol.doc(postId).set(postData);
    my.update(
      noOfPosts: FieldValue.increment(1),
    );
    Category.fromId(categoryId).update(
      noOfPosts: FieldValue.increment(1),
    );
    final post = Post.fromMap(map: postData, id: postId);
    // TODO check if correct
    FeedService.instance.create(post: post);
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

  @override
  String toString() =>
      'Post(id: $id, categoryId: $categoryId, noOfComments: $noOfComments, title: $title, content: $content, uid: $uid, urls: $urls, createdAt: $createdAt, updatedAt: $updatedAt, likes: $likes, deleted: $deleted)';

  bool get isMine {
    return UserService.instance.uid == uid;
  }
}
