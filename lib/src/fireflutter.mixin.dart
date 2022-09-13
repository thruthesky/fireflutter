import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

mixin FireFlutterMixin {
  FirebaseFirestore get db => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get userCol => db.collection('users');
  DocumentReference get myDoc => userCol.doc(_uid!);

  DocumentReference tokenDoc(String token) {
    return myDoc.collection('fcm_tokens').doc(token);
  }
}
