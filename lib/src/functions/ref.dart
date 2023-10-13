import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

const String userCollectionName = 'users';

/// Firestore database instance
FirebaseFirestore get db => FirebaseFirestore.instance;

/// Firebase Realtime Database instance
FirebaseDatabase get rtdb => FirebaseDatabase.instance;

/// user
CollectionReference get userCol =>
    FirebaseFirestore.instance.collection(userCollectionName);
DocumentReference userDoc(String uid) => userCol.doc(uid);
DocumentReference get myDoc => userDoc(FirebaseAuth.instance.currentUser!.uid);

CollectionReference get userPrivateCol =>
    FirebaseFirestore.instance.collection('user_private_data');
DocumentReference get myPrivateDoc => userPrivateCol.doc(myUid);

// categories
CollectionReference get categoryCol =>
    FirebaseFirestore.instance.collection(Category.collectionName);
DocumentReference categoryDoc(String categoryId) => categoryCol.doc(categoryId);

/// post
CollectionReference get postCol =>
    FirebaseFirestore.instance.collection('posts');
DocumentReference postDoc(String postId) => postCol.doc(postId);

CollectionReference get commentCol =>
    FirebaseFirestore.instance.collection('comments');
DocumentReference commentDoc(String postId) => postCol.doc(postId);

/// chat
CollectionReference get chatCol =>
    FirebaseFirestore.instance.collection('chats');
CollectionReference messageCol(String roomId) =>
    chatCol.doc(roomId).collection('messages');
DocumentReference roomRef(String roomId) => chatCol.doc(roomId);
DocumentReference roomDoc(String roomId) => chatCol.doc(roomId);

//
// DatabaseReference noOfNewMessageRef(String roomId) =>
//     rtdb.ref('chats/noOfNewMessages/');
//
DatabaseReference noOfNewMessageRef({required String uid}) =>
    rtdb.ref('chats/noOfNewMessages/$uid');

DocumentReference tokenDoc(String token) {
  return myDoc.collection('fcm_tokens').doc(token);
}

CollectionReference tokensCol(String uid) {
  return userCol.doc(uid).collection('fcm_tokens');
}

/// User setting
/// Note, for the sign-in user's setting, you should use `UserService.instance.settings`
/// Note, for other user settings, you should use `UserSettings(otherUid, docId)`.
CollectionReference userSettingCol(String uid) =>
    userDoc(uid).collection('user_settings');
CollectionReference get mySettingCol => userSettingCol(myUid!);

DocumentReference mySettingDoc(String documentid) =>
    mySettingCol.doc(documentid);

// favorites
CollectionReference get favoriteCol => db.collection('favorites');
DocumentReference favoriteDoc(String postId) => favoriteCol.doc(postId);

/// push notifications
CollectionReference get messageQueueCol =>
    db.collection('push_notification_queue');

/// Number of Profile View
CollectionReference get profileViewHistoryCol =>
    db.collection('profile_view_history');
DocumentReference profileViewHistoryDoc(
        {required String myUid, required String otherUid}) =>
    profileViewHistoryCol.doc('$myUid-$otherUid');

/// Returns a string of database path to the login user's block list.
///
/// [otherUid] is the uid of the user to be blocked or unblocked.
/// If [otherUid] is null or empty, it returns the path to the login user's block list.
String pathBlock(String? otherUid) {
  if (otherUid == null || otherUid.isEmpty) {
    return 'blocks/$myUid';
  } else {
    return 'blocks/$myUid/$otherUid';
  }
}

String pathSeenBy(String id) {
  return 'posts/$id/seenBy';
}

String pathPostLikedBy(String id, {bool all = false}) {
  if (all) {
    return 'posts/$id/likedBy';
  } else {
    return 'posts/$id/likedBy/$myUid';
  }
}

String pathCommentLikedBy(String id, {bool all = false}) {
  if (all) {
    return 'comments/$id/likedBy';
  } else {
    return 'comments/$id/likedBy/$myUid';
  }
}

String pathUserLiked(String id, {bool all = false}) {
  if (all) {
    return 'likes/$id';
  } else {
    return 'likes/$id/$myUid';
  }
}

/// For the path to the users' blocked list
String pathUserBlocked(String id, {bool all = false}) {
  if (all) {
    return 'blocks/$id';
  } else {
    return 'blocks/$id/$myUid';
  }
}

/// storages
CollectionReference get storageCol =>
    FirebaseFirestore.instance.collection('storages');
DocumentReference storageDoc(String storageId) => storageCol.doc(storageId);

/// reports
CollectionReference get reportCol =>
    FirebaseFirestore.instance.collection('reports');

DocumentReference reportDoc(String id) => reportCol.doc(id);

/// Activity logs
DatabaseReference get activityLogRef => rtdb.ref('activity_logs/');
