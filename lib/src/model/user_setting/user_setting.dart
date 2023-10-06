import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_setting.g.dart';

@JsonSerializable()
class UserSetting {
  final String id;
  final String uid;
  final String action;
  final String? categoryId;
  final String? roomId;

  static CollectionReference get mySettingCol =>
      FirebaseFirestore.instance.collection('users').doc(myUid!).collection('user_settings');

  UserSetting({
    required this.id,
    required this.uid,
    required this.action,
    this.categoryId,
    this.roomId,
  });

  factory UserSetting.fromJson(Map<String, dynamic> json) => _$UserSettingFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingToJson(this);

  static Future<UserSetting?> get(String id) async {
    final snapshot = await mySettingCol.where('uid', isEqualTo: my.uid).where('id', isEqualTo: id).get();
    if (snapshot.size == 0) {
      return null;
    } else {
      return UserSetting.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
  }

  /// Toggle setting.
  ///
  /// If the setting exists, it will be deleted. Or it will be created with the
  /// given data.
  ///
  /// It returns true on creation, false on deletion.
  static Future<bool> toggle({
    required String id,
    required String action,
    String? categoryId,
    String? roomId,
  }) async {
    // assert(categoryId != null || roomId != null,
    //     'categoryId or roomId must be not null');

    final setting = await get(id);
    if (setting != null) {
      await setting.delete();
      return false;
    } else {
      await UserSetting.create(
        id: id,
        action: action,
        categoryId: categoryId,
        roomId: roomId,
      );
      return true;
    }
  }

  Future delete() async {
    await mySettingDoc(id).delete();
  }

  static Future create({
    required String id,
    required String action,
    required String? categoryId,
    required String? roomId,
  }) async {
    // assert(categoryId != null || roomId != null,
    //     'categoryId or roomId must be not null');
    return await mySettingCol.doc(id).set({
      'id': id,
      'uid': myUid,
      'action': action,
      if (categoryId != null) 'categoryId': categoryId,
      if (roomId != null) 'roomId': roomId,
    });
  }
}
