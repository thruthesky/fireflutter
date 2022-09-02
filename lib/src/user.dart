import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  static CollectionReference get col => FirebaseFirestore.instance.collection('users');
  static DocumentReference get doc => col.doc(FirebaseAuth.instance.currentUser?.uid);

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static bool get notSignedIn => isAnonymous || auth.currentUser == null;

  static bool get signedIn => !notSignedIn;
  static bool get isAnonymous => auth.currentUser?.isAnonymous ?? false;

  /// TODO check if the user is admin
  static bool get isAdmin => false;

  /// ^ Even if anonymously-sign-in enabled, it still needs to be nullable.
  /// ! To avoid `null check operator` problem in the future.
  static String? get uid => auth.currentUser?.uid;

  static create() {}
  static get() {}
  static Future<void> update(Map<String, dynamic> data) {
    return doc.set({
      ...data,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  static delete() {}
}
