import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';

mixin FireFlutter {
  /// Firestore database instance
  get db => FirebaseFirestore.instance;

  /// Currently login user's uid
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  /// user
  CollectionReference get userCol => FirebaseFirestore.instance.collection(User.collectionName);
  DocumentReference userDoc(String uid) => userCol.doc(uid);
  DocumentReference get myDoc => userDoc(FirebaseAuth.instance.currentUser!.uid);

  // categories
  CollectionReference get categoryCol => FirebaseFirestore.instance.collection('categories');
  DocumentReference categoryDoc(String categoryId) => categoryCol.doc(categoryId);

  /// post
  CollectionReference get postCol => FirebaseFirestore.instance.collection('posts');
  DocumentReference postDoc(String postId) => postCol.doc(postId);

  /// chat
  CollectionReference get chatCol => FirebaseFirestore.instance.collection('chat');
  CollectionReference messageCol(String roomId) => chatCol.doc(roomId).collection('messages');
  DocumentReference roomRef(String roomId) => chatCol.doc(roomId);
  DocumentReference roomDoc(String roomId) => chatCol.doc(roomId);
}
