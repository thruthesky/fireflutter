import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class UserSettingService {
  static UserSettingService? _instance;
  static UserSettingService get instance => _instance ??= UserSettingService._();

  UserSettingService._();

  Future<UserSetting?> get({required String uid, String? id, String? action}) async {
    Query q = userSettingCol(uid);
    if (id != null) {
      q = q.where('id', isEqualTo: id);
    }
    if (action != null) {
      q = q.where('action', isEqualTo: action);
    }

    final snapshot = await q.get();
    if (snapshot.size == 0) {
      return null;
    } else {
      return UserSetting.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
  }

  Future<bool> hasUserSettingId({
    String? otherUid,
    required String id,
  }) async {
    DocumentSnapshot snapshot = await userSettingCol(otherUid ?? myUid!).doc(id).get();
    if (snapshot.exists) return true;
    return false;
  }
}
