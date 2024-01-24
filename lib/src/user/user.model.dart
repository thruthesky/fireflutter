import 'package:firebase_database/firebase_database.dart';

import 'package:fireship/fireship.dart' as fs;
import 'package:fireship/fireship.defines.dart';
import 'package:fireship/src/user/user.service.dart';

class UserModel {
  /// [data] 는 사용자 정보 문서 node 의 전체 값을 가지고 있다. 그래서, 필요할 때,
  /// data['email'] 과 같이, 필드를 직접 접근할 수 있다.
  Map<String, dynamic> data;

  final String uid;

  /// [name] 사용자의 본 명.
  ///
  /// [name] 은 사용자가 직접 입력 할 수도 있고, 본인 인증 후 자동으로 입력 될 수도 있다. 이름은 화면에 나타나지 않고,
  /// [displayName] 이 화면에 나타난다.
  ///
  /// [name] 은 fireship 에서 직접 지정하지 않는다. 개발자가 개발하는 앱내에서 직접 지정을 해야 한다.
  String name;

  /// 사용자가 직접 입력하는 별명
  String displayName;
  String email;
  String phoneNumber;
  String photoUrl;
  String profileBackgroundImageUrl;
  String stateMessage;
  bool isDisabled;
  int birthYear;
  int birthMonth;
  int birthDay;
  int createdAt;
  int order;
  bool isAdmin;
  bool isVerified;
  List<String>? blocks;

  /// 신분증 업로드한 url
  ///
  /// 신분증을 업로드하면 이 필드에 그 신분증 사진 url 이 저장된다.
  String idUrl;

  /// ID 카드(신분증) 업로드 후, 업로드 시간 저장
  ///
  /// 활용: 신분증 업로드 후, [idUploadedAt] 에 값이 있으면 관리자 페이지에 신분증 확인 대기 목록에 나타나도록 한다.
  /// 그리고, 관리자가 신분증을 수동 인증하면, isVerified 에 true 에 값을 저장하고, [idUploadedAt] 은 null
  /// 로 저장하면 된다. 만약, 인증을 취소하면, isVerified 는 false 로 저장하고, [idUploadedAt] 은
  /// 현재 시간으로 저장함녀 된다.
  int idUploadedAt;

  /// Returns true if the user is blocked.
  bool isBlocked(String otherUserUid) =>
      blocks?.contains(otherUserUid) ?? false;

  /// Alias of isBlocked
  bool hasBlocked(String otherUserUid) => isBlocked(otherUserUid);

  bool get notVerified => !isVerified;

  DatabaseReference get ref =>
      FirebaseDatabase.instance.ref('users').child(uid);

  /// See README.md
  DatabaseReference get photoRef =>
      FirebaseDatabase.instance.ref('user-profile-photos').child(uid);

  String get birth => '$birthYear-$birthMonth-$birthDay';

  UserModel({
    required this.data,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.photoUrl,
    required this.profileBackgroundImageUrl,
    required this.stateMessage,
    this.isDisabled = false,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    required this.createdAt,
    required this.order,
    this.isAdmin = false,
    this.isVerified = false,
    this.blocks,
    required this.idUrl,
    required this.idUploadedAt,
  });

  factory UserModel.fromSnapshot(DataSnapshot snapshot) {
    ///
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
      data: Map<String, dynamic>.from(json),
      uid: uid ?? json['uid'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      profileBackgroundImageUrl: json['profileBackgroundImageUrl'] ?? '',
      stateMessage: json['stateMessage'] ?? '',
      isDisabled: json['isDisabled'] ?? false,
      birthYear: json['birthYear'] ?? 0,
      birthMonth: json['birthMonth'] ?? 0,
      birthDay: json['birthDay'] ?? 0,
      createdAt: json['createdAt'] ?? 0,
      order: json['order'] ?? 0,
      isAdmin: json['isAdmin'] ?? false,
      isVerified: json['isVerified'] ?? false,
      blocks: json[Field.blocks] == null
          ? null
          : List<String>.from(
              (json[Field.blocks] as Map<Object?, Object?>)
                  .entries
                  .map((x) => x.key),
            ),
      idUrl: json[Field.idUrl] ?? '',
      idUploadedAt: json[Field.idUploadedAt] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
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
      'order': order,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
      Field.blocks:
          blocks == null ? null : List<dynamic>.from(blocks!.map((x) => x)),
      Field.idUrl: idUrl,
      Field.idUploadedAt: idUploadedAt,
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
      name = user.name;
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
      order = user.order;
      isAdmin = user.isAdmin;
      isVerified = user.isVerified;
      blocks = user.blocks;
      idUrl = user.idUrl;
      idUploadedAt = user.idUploadedAt;
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
  ///
  /// ```dart
  /// UserModel.getField(uid, Field.isVerified);
  /// ```
  static Future<T?> getField<T>(String uid, String field) async {
    final nodeData = await fs.get('users/$uid/$field');
    if (nodeData == null) {
      return null;
    }

    return nodeData as T;
  }

  /// Create user document
  ///
  /// This returns UserModel of the created user document.
  static Future<UserModel> create({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    await fs.set(
      '${Folder.users}/$uid',
      {
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': ServerValue.timestamp,
        'order': DateTime.now().millisecondsSinceEpoch * -1,
      },
    );

    final created = await UserModel.get(uid);
    UserService.instance.onCreate?.call(created!);
    return created!;
  }

  /// Update user data.
  ///
  /// All user data fields must be updated with this method.
  ///
  /// hasPhotoUrl is automatically set to true if photoUrl is not null.
  ///
  /// [photoUrl] 값이 빈 문자열이면, 해당 필드는 삭제되고, hasPhotoUrl 도 false 로 저장된다.
  Future<UserModel> update({
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
    dynamic createdAt,
    dynamic order,
    int? idUploadedAt,
    String? idUrl,
  }) async {
    final data = {
      if (name != null) 'name': name,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (profileBackgroundImageUrl != null)
        'profileBackgroundImageUrl': profileBackgroundImageUrl,
      if (stateMessage != null) 'stateMessage': stateMessage,
      if (photoUrl != null) 'hasPhotoUrl': true,
      if (birthYear != null) 'birthYear': birthYear,
      if (birthMonth != null) 'birthMonth': birthMonth,
      if (birthDay != null) 'birthDay': birthDay,
      if (isAdmin != null) 'isAdmin': isAdmin,
      if (isVerified != null) 'isVerified': isVerified,
      if (createdAt != null) 'createdAt': createdAt,
      if (order != null) 'order': order,
      if (idUploadedAt != null) 'idUploadedAt': idUploadedAt,
      if (idUrl != null) 'idUrl': idUrl,
    };
    if (data.isEmpty) {
      return this;
    }

    // 업데이트부터 하고
    await fs.update(
      'users/$uid',
      data,
    );

    /// 사용자 객체(UserModel) 를 reload 하고, (주의: 로그인한 사용자의 정보가 아닐 수 있다.)
    await reload();
    // final updated = await UserModel.get(uid);

    /// 사진 정보 업데이트
    if (displayName != null || photoUrl != null) {
      await _updateUserProfilePhotos(
          displayName: displayName, photoUrl: photoUrl);
    }

    UserService.instance.onUpdate?.call(this);
    return this;
  }

  /// 사진 순서로 목록하기 위한 정보
  ///
  /// 사진 목록 경로(정보)에는 createdAt 보다는 updatedAt 을 사용한다.
  ///
  /// 사진 목록에는 이름과 날짜, 사진 url 이 저장된다. 따라서, 둘 중 하나만 변경되어도 업데이트를 한다.
  /// 단, 이름을 업데이트 할 때에는 updatedAt 를 생성하지 않는다. 즉, 이미지가 있어야지만, 검색이 되도록 한다.
  ///
  Future<void> _updateUserProfilePhotos({
    String? displayName,
    String? photoUrl,
  }) async {
    if (displayName == null && photoUrl == null) {
      return;
    }
    if (photoUrl == "") {
      await photoRef.remove();
    } else {
      await photoRef.update({
        if (photoUrl != null) Field.photoUrl: photoUrl,
        if (displayName != null) Field.displayName: displayName,
        if (photoUrl != null)
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

  /// 인증 완료 설정
  ///
  /// 관리자가 수동으로 신분증을 인증하면, 해당 사용자는 완전히 인증된 것이다.
  Future<void> setVerified() async {
    await ref.update({
      Field.isVerified: true,
      Field.idUploadedAt: null,
    });
  }

  /// 인증 취소
  ///
  /// 해당 사용자는 인증 대기 목록에 표시된다.
  Future<void> setUnverified() async {
    await ref.update({
      Field.isVerified: null,
      Field.idUploadedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 신분증 업로드
  Future<UserModel> setVerificationIdUrl(String url) async {
    return await update(
      idUploadedAt: DateTime.now().millisecondsSinceEpoch,
      idUrl: url,
    );
  }

  /// 신분증 업로드한 사진 URL 과 idUpdatedAt 을 삭제.
  ///
  /// 사용자는 다시 신분증을 업로드 해야 한다.
  Future<void> deleteVerification() async {
    await ref.update({
      Field.idUrl: null,
      Field.idUploadedAt: null,
    });
  }

  /// Blocks or unblocks
  ///
  /// After this method call, the user is blocked or unblocked.
  /// Returns true if the user has just blocked blocked, false if unblocked.
  ///
  Future block(String otherUserUid) async {
    if (otherUserUid == uid) {
      throw fs.Issue(fs.Code.blockSelf, 'You cannot block yourself.');
    }
    //
    if (isBlocked(otherUserUid)) {
      await unblockUser(otherUserUid);
      return false;
    } else {
      await blockUser(otherUserUid);
      return true;
    }
  }

  /// Block a user
  Future blockUser(String otherUserUid) async {
    return await ref.child(Field.blocks).child(otherUserUid).set(
          ServerValue.timestamp,
        );
  }

  /// Unblock a user
  ///
  /// Remove the user from the block list by setting null value
  Future unblockUser(String otherUserUid) async {
    return await ref.child(Field.blocks).child(otherUserUid).set(null);
  }
}
