import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final String uid;
  final List<dynamic>? files;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final List<dynamic> likers;
  final bool? deleted;

  Post({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.uid,
    this.files,
    required this.createdAt,
    required this.updatedAt,
    required this.likers,
    this.deleted,
  });

  factory Post.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Post.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Post.fromMap({required Map<String, dynamic> map, required id}) {
    return Post(
      id: id,
      categoryId: map['categoryId'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      uid: map['uid'] ?? '',
      files: map['files'],
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
      likers: map['likers'] ?? [],
      deleted: map['deleted'],
    );
  }

  static Future<Post> create({
    required String categoryId,
    required String title,
    required String content,
    required String uid,
    List<String>? files,
  }) async {
    return Post.fromMap(map: map, id: id);
  }
}
