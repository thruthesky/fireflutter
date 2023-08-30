import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class User with FirebaseHelper {
  static const String collectionName = 'users';

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  late Map<String, dynamic> data;

  @override
  final String uid;

  /// [isAdmin] is set to true if the logged in user is an admin.
  bool isAdmin = false;

  /// 만약, dsiplayName 이 없으면, uid 의 앞 두글자를 대문자로 표시.
  final String displayName;
  final String name;
  final String firstName;
  final String lastName;
  final String middleName;
  final String photoUrl;

  /// ID 카드(신분증)으로 인증된 사용자의 경우, 인증 코드.
  /// 신분증 등록 후, 텍스트 추출 -> 이름 대조 또는 기타 방법으로 인증된 사용자의 경우 true
  ///
  /// 이 값은 다양하게 응용해서 활용하면 된다. 예) 신분증 업로드 후, 신분증 경로 URL 을 저장하거나, 파일 이름 또는 기타 코드를 입력하면 된다.
  final String idVerifiedCode;

  ///
  final String phoneNumber;
  final String email;

  /// User state. It's like user's status or mood, motto. You can save whatever here.
  /// 상태. 개인의 상태, 무드, 인사말 등. 예를 들어, 휴가중. 또는 모토. 인생은 모험이 아니면 아무것도 아닙니다.
  final String state;

  /// User public profile title image
  final String stateImageUrl;

  final int birthYear;
  final int birthMonth;
  final int birthDay;

  /// [type] is a string value that can be used to categorize the user. You can
  /// think of it as a member type. For example, you can set it to 'player' or
  /// 'coach' or 'admin' or 'manager' or 'staff' or 'parent' or 'fan' or
  /// 'student', 'guest', etc...
  final String type;

  /// Indicates whether the user has a photoUrl.
  ///
  /// Note this value is automatically set to true when the user uploads a photo by the easy-extension
  /// So, don't set this value manually.
  /// And this is available only on `/search-user-data` in Firestore or `/users` in Realtime Database.
  /// It does not exists in `/users` in Firestore.
  ///
  final bool hasPhotoUrl;

  /// 사용자 문서가 생성된 시간. 항상 존재 해야 함. Firestore 서버 시간
  final Timestamp? createdAt;

  /// Dart 에서 사용 할 createAt 의 DateTime 값.
  final DateTime? createdAtDateTime;

  /// Set this to true when the user has completed the profile.
  /// This should be set when the user submit the profile form.
  ///
  /// 사용자가 회원 정보를 업데이트 할 때, 이 값을 true 또는 false 로 지정한다.
  /// 이 값이 false 이면, 앱에서 회원 정보를 입력하라는 메시지를 표시하거나 기타 동작을 하게 할 수 있다.
  final bool complete;

  /// 사용자 문서가 존재하지 않는 경우, 이 값이 false 이다.
  /// 특히, 이 값이 false 이면 사용자 로그인을 했는데, 사용자 문서가 존재하지 않는 경우이다.
  final bool exists;

  bool cached = false;

  User({
    required this.uid,
    this.isAdmin = false,
    this.displayName = '',
    this.name = '',
    this.firstName = '',
    this.lastName = '',
    this.middleName = '',
    this.photoUrl = '',
    this.hasPhotoUrl = false,
    this.idVerifiedCode = '',
    this.phoneNumber = '',
    this.email = '',
    this.state = '',
    this.stateImageUrl = '',
    this.birthYear = 0,
    this.birthMonth = 0,
    this.birthDay = 0,
    this.type = '',
    this.createdAt,
    this.complete = false,
    this.exists = true,
    this.data = const {},
  }) : createdAtDateTime = createdAt?.toDate();

  factory User.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return User.fromMap(
      map: documentSnapshot.data() as Map<String, dynamic>,
      id: documentSnapshot.id,
    );
  }

  factory User.fromMap({required Map<String, dynamic> map, required String id}) {
    final displayName = map['displayName'] ?? '';

    // The createdAt may be int (from RTDB) or Timestamp (from Fireestore), or null.
    if (map['createdAt'] is int) {
      map['createdAt'] = Timestamp.fromMillisecondsSinceEpoch(map['createdAt'] as int);
    } else if (map['createdAt'] is Timestamp) {
      map['createdAt'] = map['createdAt'] as Timestamp;
    } else {
      map['createdAt'] = null;
    }

    return User(
      uid: id,
      isAdmin: map['isAdmin'] ?? false,
      displayName: displayName == '' ? id.toUpperCase().substring(0, 2) : displayName,
      name: map['name'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      middleName: map['middleName'] ?? '',
      photoUrl: (map['photoUrl'] ?? '') as String,
      hasPhotoUrl: map['hasPhotoUrl'] ?? false,
      idVerifiedCode: map['idVerifiedCode'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      state: map['state'] ?? '',
      stateImageUrl: map['stateImageUrl'] ?? '',
      birthYear: map['birthYear'] ?? 0,
      birthMonth: map['birthMonth'] ?? 0,
      birthDay: map['birthDay'] ?? 0,
      type: map['type'] ?? '',
      createdAt: map['createdAt'],
      complete: map['complete'] ?? false,
      data: map,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'isAdmin': isAdmin,
      'displayName': displayName,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'photoUrl': photoUrl,
      'hasPhotoUrl': hasPhotoUrl,
      'idVerifiedCode': idVerifiedCode,
      'phoneNumber': phoneNumber,
      'email': email,
      'state': state,
      'stateImageUrl': stateImageUrl,
      'birthYear': birthYear,
      'birthMonth': birthMonth,
      'birthDay': birthDay,
      'type': type,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'complete': complete,
    };
  }

  @override
  String toString() =>
      '''User(uid: $uid, isAdmin: $isAdmin, name: $name, firstName: $firstName, lastName: $lastName, middleName: $middleName, displayName: $displayName, photoUrl: $photoUrl, hasPhotoUrl: $hasPhotoUrl, idVerifiedCode: $idVerifiedCode, phoneNumber: $phoneNumber, email: $email, state: $state, stateImageUrl: $stateImageUrl, birthYear: $birthYear, birthMonth: $birthMonth, birthDay: $birthDay, type: $type, createdAt: $createdAt, createdAtDateTime: $createdAtDateTime, complete: $complete, exists: $exists, cached: $cached)''';

  /// Get user document
  ///
  /// If the user document does not exist, it will return null. It does not throw an exception.
  ///
  /// It does not
  static Future<User?> get(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).doc(uid).get();
    if (snapshot.exists == false) {
      return null;
    }
    return User.fromDocumentSnapshot(snapshot);
  }

  /// 사용자 문서를 Realtime Database 에 Sync 된 문서를 읽어 온다.
  static Future<User?> getFromDatabaseSync(String uid) async {
    final snapshot = await FirebaseDatabase.instance.ref().child(collectionName).child(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return User.fromMap(map: Map<String, dynamic>.from(snapshot.value as Map), id: uid);
  }

  /// 사용자 문서를 생성한다.
  ///
  /// 사용자 문서가 이미 존재하는 경우, 문서를 덮어쓴다.
  /// 참고: README.md
  ///
  /// Example;
  /// ```dart
  /// User.create(uid: 'xxx');
  /// ```
  static Future<User> create({required String uid}) async {
    await FirebaseFirestore.instance.collection(User.collectionName).doc(uid).set({
      'uid': uid,
      'email': '',
      'displayName': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return (await get(uid))!;
  }

  /// Updaet user document
  ///
  /// Update the user document under /users/{uid} for the login user.
  ///
  /// Note that, the document update for your profile information update is
  /// not an expensive work. So, it gets the user document from Firestore
  /// after update the document and it returns the user model from the updated
  /// user document. but there might be some fields that are not updated by
  /// the cloud (background) function.
  Future<User> update({
    String? name,
    String? firstName,
    String? lastName,
    String? middleName,
    String? displayName,
    String? photoUrl,
    bool? hasPhotoUrl,
    String? idVerifiedCode,
    String? phoneNumber,
    String? email,
    String? state,
    String? stateImageUrl,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    String? type,
    bool? complete,
    String? field,
    dynamic value,
    Map<String, dynamic> data = const {},
  }) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);

    await doc.update({
      ...{
        if (name != null) 'name': name,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (middleName != null) 'middleName': middleName,
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (hasPhotoUrl != null) 'hasPhotoUrl': hasPhotoUrl,
        if (idVerifiedCode != null) 'idVerifiedCode': idVerifiedCode,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
        if (state != null) 'state': state,
        if (stateImageUrl != null) 'stateImageUrl': stateImageUrl,
        if (birthYear != null) 'birthYear': birthYear,
        if (birthMonth != null) 'birthMonth': birthMonth,
        if (birthDay != null) 'birthDay': birthDay,
        if (type != null) 'type': type,
        if (complete != null) 'complete': complete,
        if (field != null && value != null) field: value,
      },
      ...data
    });

    return (await get(uid))!;
  }

  /// If the user has completed the profile, set the complete field to true.
  Future<User> updateComplete(bool complete) async {
    return await update(complete: complete);
  }
}
