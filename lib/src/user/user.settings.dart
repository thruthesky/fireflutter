import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class UserSettings {
  String documentId = 'settings';

  /// UserSettings 에 기본 문서 ID 를 지정해서 리턴한다.
  ///
  /// 예)
  /// ```dart
  /// await UserService.instance.settings.doc(id).update({ 'action': '$type-create', 'category': category.id,  });
  /// ```
  UserSettings doc(String id) {
    return UserSettings()..documentId = id;
  }

  CollectionReference get col =>
      UserService.instance.doc.collection('user_settings');

  Future<void> update(Map<String, dynamic> data) {
    return col.doc(documentId).set(data, SetOptions(merge: true));
  }

  /// Gets the document.
  ///
  /// ```dart
  /// int? createdAt = (await UserService.instance.settings.get())?[lastTestDocCreatedAt];
  /// ```
  Future<Map<String, dynamic>?> get() async {
    final snapshot = await col.doc(documentId).get();
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> delete() {
    return col.doc(documentId).delete();
  }
}
