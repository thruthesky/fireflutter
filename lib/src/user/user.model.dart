import 'package:firebase_database/firebase_database.dart';

import 'package:fireship/fireship.dart' as fs;
import 'package:fireship/fireship.defines.dart';
import 'package:fireship/src/common/exception/code.dart';

class UserModel {
  final String uid;
  String? email;
  String? phoneNumber;
  String? displayName;
  String? photoUrl;
  String? profileBackgroundImageUrl;
  String? stateMessage;
  bool isDisabled;
  int? birthYear;
  int? birthMonth;
  int? birthDay;
  int? createdAt;
  bool isAdmin;
  bool isVerified;

  DatabaseReference get ref => FirebaseDatabase.instance.ref('users').child(uid);

  /// See README.md
  DatabaseReference get photoRef => FirebaseDatabase.instance.ref('user-profile-photos').child(uid);

  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.profileBackgroundImageUrl,
    this.stateMessage,
    this.isDisabled = false,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.createdAt,
    this.isAdmin = false,
    this.isVerified = false,
  });

  factory UserModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['uid'] = snapshot.key;
    return UserModel.fromJson(json);
  }

  /// 사용자 uid 로 부터, UserModel 을 만들어, 빈 UserModel 을 리턴한다.
  ///
  /// 즉, 생성된 UserModel 의 instance 에서, uid 를 제외한 모든 properties 는 null 이지만,
  /// uid 를 기반으로 하는, 각종 method 를 쓸 수 있다.
  ///
  /// 예를 들면, UserModel.fromUid(uid).ref.child('photoUrl').onValue 등과 같이 쓸 수 있으며,
  /// update(), delete() 함수 등을 쓸 수 있다.
  ///
  /// 만약, uid 만으로 사용자 정보 전체를 다 가지고 싶다면,
  factory UserModel.fromUid(String uid) {
    return UserModel.fromJson({
      'uid': uid,
    });
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return UserModel(
      uid: uid ?? json['uid'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      profileBackgroundImageUrl: json['profileBackgroundImageUrl'],
      stateMessage: json['stateMessage'],
      isDisabled: json['isDisabled'] ?? false,
      birthYear: json['birthYear'],
      birthMonth: json['birthMonth'],
      birthDay: json['birthDay'],
      createdAt: json['createdAt'],
      isAdmin: json['isAdmin'] ?? false,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'profileBackgroundImageUrl': profileBackgroundImageUrl,
      'stateMessage': stateMessage,
      'isDisabled': isDisabled,
      'birthYear': birthYear,
      'birthMonth': birthMonth,
      'birthDay': birthDay,
      'createdAt': createdAt,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
    };
  }

  @override
  String toString() {
    return 'UserModel(${toJson()})';
  }

  /// Reload user data and apply it to this instance.
  Future<UserModel> reload() async {
    final user = await UserModel.get(uid);

    if (user != null) {
      email = user.email;
      phoneNumber = user.phoneNumber;
      displayName = user.displayName;
      photoUrl = user.photoUrl;
      profileBackgroundImageUrl = user.profileBackgroundImageUrl;
      stateMessage = user.stateMessage;
      isDisabled = user.isDisabled;
      birthYear = user.birthYear;
      birthMonth = user.birthMonth;
      birthDay = user.birthDay;
      createdAt = user.createdAt;
      isAdmin = user.isAdmin;
      isVerified = user.isVerified;
    }

    return this;
  }

  /// 사용자 정보 node 전체를 리턴한다.
  static Future<UserModel?> get(String uid) async {
    final nodeData = await fs.get<Map<dynamic, dynamic>>('users/$uid');
    if (nodeData == null) {
      return null;
    }

    nodeData['uid'] = uid;
    return UserModel.fromJson(nodeData);
  }

  /// 사용자의 특정 필만 가져와서 리턴한다.
  static Future<T?> getField<T>(String uid, String field) async {
    final nodeData = await fs.get('users/$uid/$field');
    if (nodeData == null) {
      return null;
    }

    return nodeData as T;
  }

  /// Update user data.
  ///
  /// hasPhotoUrl is automatically set to true if photoUrl is not null.
  Future<void> update({
    String? name,
    String? displayName,
    String? photoUrl,
    String? profileBackgroundImageUrl,
    String? stateMessage,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    bool? isAdmin,
    bool? isVerified,
  }) async {
    final data = {
      if (name != null) 'name': name,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (profileBackgroundImageUrl != null) 'profileBackgroundImageUrl': profileBackgroundImageUrl,
      if (stateMessage != null) 'stateMessage': stateMessage,
      if (photoUrl != null) 'hasPhotoUrl': true,
      if (birthYear != null) 'birthYear': birthYear,
      if (birthMonth != null) 'birthMonth': birthMonth,
      if (birthDay != null) 'birthDay': birthDay,
      if (isAdmin != null) 'isAdmin': isAdmin,
      if (isVerified != null) 'isVerified': isVerified,
    };
    if (data.isEmpty) {
      return;
    }

    await fs.update(
      'users/$uid',
      data,
    );

    if (photoUrl != null) {
      /// createdAt 정보는 없어서, 저장 할 수 없다.
      await photoRef.set({
        Field.photoUrl: photoUrl,
        Field.updatedAt: DateTime.now().millisecondsSinceEpoch * -1,
      });
    }
  }

  /// Delete user data.
  ///
  /// update() 메소드에 필드를 null 로 주면, 해당 필드가 삭제되지 않고 그냐 그대로 유지된다.
  /// 그래서, delete() 메소드를 따로 만들어서 사용한다.
  Future<void> deletePhotoUrl() async {
    await fs.update(
      'users/$uid',
      {
        Field.photoUrl: null,
        Field.hasPhotoUrl: false,
      },
    );

    await photoRef.remove();
  }
}
