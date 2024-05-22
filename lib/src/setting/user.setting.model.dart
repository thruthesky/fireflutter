import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// User setting data modeling class
///
///
class UserSetting {
  static const String node = 'user-settings';

  static DatabaseReference get rootRef => FirebaseDatabase.instance.ref();
  static DatabaseReference get nodeRef => rootRef.child(node);

  /// Member variables
  final String key;
  final bool? profileViewNotification;
  final bool? commentNotification;
  final String? languageCode;

  final DatabaseReference ref;

  UserSetting({
    required this.key,
    required this.ref,
    required this.profileViewNotification,
    required this.commentNotification,
    required this.languageCode,
  });

  /// Return a new UserSetting with the given data
  factory UserSetting.fromSnapshot(DataSnapshot snapshot) {
    return UserSetting.fromJson(snapshot.value as Map, snapshot.key!);
  }

  /// Return a new UserSetting with the given data
  factory UserSetting.fromJson(Map<dynamic, dynamic> json, String key) {
    return UserSetting(
      key: key,
      ref: nodeRef.child(key),
      profileViewNotification: json[Field.profileViewNotification],
      commentNotification: json[Field.commentNotification],
      languageCode: json[Field.languageCode],
    );
  }

  /// Return a new UserSetting with the given uid.
  ///
  /// Use this when you want to create an empty UserSetting with the given uid
  /// to use its member variables and methods.
  ///
  /// You can use this especially when the user has not set the settings yet.
  /// Or the user is new and has not set the settings before.
  factory UserSetting.fromUid(String uid) {
    return UserSetting.fromJson(
      {
        Field.profileViewNotification: null,
        Field.languageCode: null,
        Field.commentNotification: null,
      },
      uid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      Field.profileViewNotification: profileViewNotification,
      Field.languageCode: languageCode,
    };
  }

  /// Returns the login user's UserSetting with the database data.
  ///
  /// If the user has no setting data in database, it will return an empty
  /// UserSetting, meaning it does not return null even if the setting data
  /// of the user does not exist.
  static Future<UserSetting> get(String uid) async {
    final snapshot = await nodeRef.child(uid).get();
    if (snapshot.exists) {
      return UserSetting.fromSnapshot(snapshot);
    } else {
      return UserSetting.fromUid(uid);
    }
  }

  /// Get the value of the field
  static Future<T?> getField<T>(String uid, String field) async {
    final snapshot = await nodeRef.child(uid).child(field).get();
    if (snapshot.exists) {
      return snapshot.value as T;
    } else {
      return null;
    }
  }

  /// Update the user setting data
  ///
  /// If the value is null, it will not be updated.
  ///
  /// null 을 저장할 수 없다. false 로 저장해야 한다. 즉, null 을 저장해서, 해당 필드를 삭제하려면, 이 함수를 사용해서는 안되고
  /// 다른 방법을 사용해야 한다.
  update({
    bool? profileViewNotification,
    String? languageCode,
    bool? commentNotification,
  }) async {
    await ref.update({
      if (profileViewNotification != null)
        Field.profileViewNotification: profileViewNotification,
      if (languageCode != null) Field.languageCode: languageCode,
      if (commentNotification != null)
        Field.commentNotification: commentNotification,
    });
  }
}
