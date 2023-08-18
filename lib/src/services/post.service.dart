import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  static PostService? _instance;
  static PostService get instance => _instance ??= PostService._();
  PostService._();

  CollectionReference get postCol => FirebaseFirestore.instance.collection('posts');
  DocumentReference postDoc(String postId) => postCol.doc(postId);

  /// TODO: Support official localization.
  Map<String, String> texts = {};
}
