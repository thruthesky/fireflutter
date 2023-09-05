import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_database/firebase_database.dart';

mixin FirebaseHelper {
  /// Firestore database instance
  FirebaseFirestore get db => FirebaseFirestore.instance;

  /// Firebase Realtime Database instance
  FirebaseDatabase get rtdb => FirebaseDatabase.instance;

  /// Currently login user's uid
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  /// user
  CollectionReference get userCol => FirebaseFirestore.instance.collection(User.collectionName);
  DocumentReference userDoc(String uid) => userCol.doc(uid);
  DocumentReference get myDoc => userDoc(FirebaseAuth.instance.currentUser!.uid);

  CollectionReference get userSearchCol => FirebaseFirestore.instance.collection('user_search_data');

  // categories
  CollectionReference get categoryCol => FirebaseFirestore.instance.collection(Category.collectionName);
  DocumentReference categoryDoc(String categoryId) => categoryCol.doc(categoryId);

  /// post
  CollectionReference get postCol => FirebaseFirestore.instance.collection('posts');
  DocumentReference postDoc(String postId) => postCol.doc(postId);

  /// comment
  CollectionReference get commentCol => FirebaseFirestore.instance.collection('comments');
  DocumentReference commentDoc(String postId) => postCol.doc(postId);

  /// chat
  CollectionReference get chatCol => FirebaseFirestore.instance.collection('chats');
  CollectionReference messageCol(String roomId) => chatCol.doc(roomId).collection('messages');
  DocumentReference roomRef(String roomId) => chatCol.doc(roomId);
  DocumentReference roomDoc(String roomId) => chatCol.doc(roomId);

  //
  DatabaseReference noOfNewMessageRef(String roomId) => rtdb.ref('chats/$roomId/noOfNewMessages');
  //
  DatabaseReference noOfNewMessageUserRef(String roomId, String uid) => noOfNewMessageRef(roomId).child(uid);

  DocumentReference tokenDoc(String token) {
    return myDoc.collection('fcm_tokens').doc(token);
  }

  /// User setting
  /// Note, for the sign-in user's setting, you should use `UserService.instance.settings`
  /// Note, for other user settings, you should use `UserSettings(otherUid, docId)`.
  CollectionReference userSettingsCol(String uid) => userDoc(uid).collection('user_settings');

  // favorites
  CollectionReference get favoriteCol => db.collection('favorites');
  DocumentReference favoriteDoc(String postId) => favoriteCol.doc(postId);
}
