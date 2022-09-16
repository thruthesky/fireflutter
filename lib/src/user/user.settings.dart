import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

/// Manage the Firestore-like access on user settings.
/// It supports `doc()`, `path`, `snapshot()`, `get()`, etc.
///
/// To get the document reference,
/// ```dart
/// UserService.instance.settings.col.doc("chat.$uid");
/// ```
///
/// To get the path of the document, use one of the below.
/// ```dart
/// UserService.instance.settings.col.doc("chat.$uid").path;
/// UserService.instance.settings.doc("chat.$uid");
/// ```
///
/// To get other user's setting document
/// ```
/// final doc = await UserSettings(uid: uid, documentId: 'chat.${UserService.instance.uid}').get();
/// if (doc == null) print('document does not exist');
/// else print('document: $doc');
/// ```
class UserSettings {
  UserSettings({this.uid, this.documentId = 'settings'});
  String? uid;
  String documentId = 'settings';

  String get path => col.doc(documentId).path;
  Stream<DocumentSnapshot<Object?>> snapshot() =>
      col.doc(documentId).snapshots();

  /// UserSettings 에 기본 문서 ID 를 지정해서 리턴한다.
  ///
  /// 예)
  /// ```dart
  /// await UserService.instance.settings.doc(id).update({ 'action': '$type-create', 'category': category.id,  });
  /// ```
  UserSettings doc(String id) {
    return UserSettings()..documentId = id;
  }

  CollectionReference get col => uid != null
      ? FireFlutterService.instance.userSettingsCol(uid!)
      : UserService.instance.doc.collection('user_settings');

  Future<void> update(Map<String, dynamic> data) {
    return col.doc(documentId).set(data, SetOptions(merge: true));
  }

  /// Gets the document.
  ///
  /// ```dart
  /// int? createdAt = (await UserService.instance.settings.get())?[lastTestDocCreatedAt];
  /// ```
  ///
  /// If there the document does not exists, it returns null.
  Future<Map<String, dynamic>?> get() async {
    final ref = col.doc(documentId);
    // print('---> ref: ${ref.path}');
    final snapshot = await ref.get();
    if (snapshot.exists == false) return null;
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> delete() {
    return col.doc(documentId).delete();
  }
}
