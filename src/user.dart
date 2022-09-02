import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  static CollectionReference get col => FirebaseFirestore.instance.collection('users');
  static DocumentReference get doc => col.doc(FirebaseAuth.instance.currentUser?.uid);
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
