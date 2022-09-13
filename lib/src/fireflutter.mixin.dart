import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

@Deprecated('User FireFlutter.instance.xxx or Model methods')
mixin FireFlutterMixin {
  BuildContext get context => FireFlutterService.instance.context;

  FirebaseFirestore get db => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get userCol => db.collection('users');
  DocumentReference get myDoc => userCol.doc(_uid!);
  DocumentReference userDoc(String uid) => userCol.doc(uid);

  DocumentReference tokenDoc(String token) {
    return myDoc.collection('fcm_tokens').doc(token);
  }

  bool get signedIn => UserService.instance.signedIn;
  bool get notSignedIn => UserService.instance.notSignedIn;

  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get commentCol => db.collection('comments');

  CollectionReference get reportCol => db.collection('reports');
  CollectionReference get feedCol => db.collection('feeds');

  // Global (system) settings for app setting.
  CollectionReference get settingDoc => db.collection('settings');

  // User setting
  CollectionReference userSettingsCol(String uid) =>
      userDoc(uid).collection('user_settings');
  DocumentReference userSettingsDoc(String uid) =>
      userSettingsCol(uid).doc('settings');

  // Returns user settings.
  Future<Map<String, dynamic>?> mySettings() async {
    return await FireFlutterMixin.userSettings_();
  }

  Future<void> updateMySettings(Map<String, dynamic> data,
      {String id = 'settings'}) async {
    return await userSettingsCol(UserService.instance.uid!)
        .doc(id)
        .set(data, SetOptions(merge: true));
  }

  Future<void> deleteMySettings(String id) async {
    return await userSettingsCol(UserService.instance.uid!).doc(id).delete();
  }

  // Returns user settings.
  static Future<Map<String, dynamic>?> userSettings_() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(UserService.instance.uid!)
        .collection('user_settings')
        .doc('settings')
        .get();
    return snapshot.data() as Map<String, dynamic>;
  }

  // Forum category menus
  DocumentReference get forumSettingDoc => settingDoc.doc('forum');

  // Forum category menus
  DocumentReference reportDoc(String id) => reportCol.doc(id);

  // Jobs
  CollectionReference get jobs => db.collection('jobs');
  CollectionReference get jobSeekers => db.collection('job-seekers');

  DocumentReference categoryDoc(String id) {
    return db.collection('categories').doc(id);
  }

  DocumentReference postDoc(String id) {
    return postCol.doc(id);
  }
}
