import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_database/firebase_database.dart';

/// FirebaseHelper
///
/// Use method from ref.dart
@Deprecated('Use reference method from ref.dart')
mixin FirebaseHelper {
  /// Firestore database instance
  FirebaseFirestore get db => FirebaseFirestore.instance;

  /// Firebase Realtime Database instance
  FirebaseDatabase get rtdb => FirebaseDatabase.instance;

  /// Currently login user's uid
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  /// user
  CollectionReference get userCol => FirebaseFirestore.instance.collection(userCollectionName);
  DocumentReference userDoc(String uid) => userCol.doc(uid);
  DocumentReference get myDoc => userDoc(FirebaseAuth.instance.currentUser!.uid);

  CollectionReference get userSearchCol => FirebaseFirestore.instance.collection('user_search_data');

  DocumentReference get mySearchDoc => userSearchCol.doc(uid);

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
  // DatabaseReference noOfNewMessageRef(String roomId) =>
  //     rtdb.ref('chats/noOfNewMessages/');
  //
  DatabaseReference noOfNewMessageRef({required String uid}) => rtdb.ref('chats/noOfNewMessages/$uid');

  DocumentReference tokenDoc(String token) {
    return myDoc.collection('fcm_tokens').doc(token);
  }

  CollectionReference tokensCol(String uid) {
    return userCol.doc(uid).collection('fcm_tokens');
  }

  /// User setting
  /// Note, for the sign-in user's setting, you should use `UserService.instance.settings`
  /// Note, for other user settings, you should use `UserSettings(otherUid, docId)`.
  CollectionReference userSettingCol(String uid) => userDoc(uid).collection('user_settings');
  CollectionReference get mySettingCol => userSettingCol(myUid!);

  DocumentReference mySettingDoc(String documentid) => mySettingCol.doc(documentid);

  // favorites
  CollectionReference get favoriteCol => db.collection('favorites');
  DocumentReference favoriteDoc(String postId) => favoriteCol.doc(postId);

  /// push notifications
  CollectionReference get messageQueueCol => db.collection('push_notification_queue');

  /// Number of Profile View
  CollectionReference get profileViewHistoryCol => db.collection('profile_view_history');
  DocumentReference profileViewHistoryDoc({required String myUid, required String otherUid}) =>
      profileViewHistoryCol.doc('$myUid-$otherUid');
}
