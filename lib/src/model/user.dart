import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class User with FirebaseHelper {
  static const String collectionName = 'users';

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

  /// 상태. 개인의 상태. 예를 들어, 휴가중. 또는 모토. 인생은 모험이 아니면 아무것도 아닙니다.
  final String state;

  final int birthYear;
  final int birthMonth;
  final int birthDay;

  /// DB 에 저장되는 값. 그래야 검색이 가능.
  /// 주의: DB 검색용으로만 써야 한다. 왜냐하면, photoUrl 값이 삭제되면, 이 값이 false 가 되어야하는데,
  /// (실수로 그렇지 않고 계속) true 값을 가질 수 있다. 예를 들면, 테스트 할 때, 수동으로 photoUrl 만 삭제 할 때, 등...
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
    this.birthYear = 0,
    this.birthMonth = 0,
    this.birthDay = 0,
    this.createdAt,
    this.complete = false,
    this.exists = true,
  }) : createdAtDateTime = createdAt?.toDate();

  factory User.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return User.fromMap(
      map: documentSnapshot.data() as Map<String, dynamic>,
      id: documentSnapshot.id,
    );
  }

  factory User.fromMap({required Map<String, dynamic> map, required String id}) {
    final displayName = map['displayName'] ?? '';
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
      birthYear: map['birthYear'] ?? 0,
      birthMonth: map['birthMonth'] ?? 0,
      birthDay: map['birthDay'] ?? 0,
      createdAt: map['createdAt'],
      complete: map['complete'] ?? false,
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
      'birthYear': birthYear,
      'birthMonth': birthMonth,
      'birthDay': birthDay,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'complete': complete,
    };
  }

  @override
  String toString() =>
      '''User(uid: $uid, isAdmin: $isAdmin, name: $name, firstName: $firstName, lastName: $lastName, middleName: $middleName, displayName: $displayName, photoUrl: $photoUrl, hasPhotoUrl: $hasPhotoUrl, idVerifiedCode: $idVerifiedCode, phoneNumber: $phoneNumber, email: $email, birthYear: $birthYear, birthMonth: $birthMonth, birthDay: $birthDay, createdAt: $createdAt, createdAtDateTime: $createdAtDateTime, complete: $complete, exists: $exists, cached: $cached)''';

  /// 사용자 문서를 읽어온다.
  ///
  /// 사용자 문서가 존재하지 않는 경우, null 을 리턴한다.
  /// 캐시하지 않는다.
  static Future<User?> get(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return User.fromDocumentSnapshot(snapshot);
  }

  /// 사용자 문서를 생성한다.
  ///
  /// 사용자 문서가 이미 존재하는 경우, 문서를 덮어쓴다.
  /// 참고: README.md
  Future<User> create() async {
    await FirebaseFirestore.instance.collection(User.collectionName).doc(uid).set(toMap());

    return (await get(uid))!;
  }

  /// Update the user document under /users/{uid} for the login user.
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
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    bool? complete,
    String? field,
    dynamic value,
  }) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);

    await doc.update({
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
      if (birthYear != null) 'birthYear': birthYear,
      if (birthMonth != null) 'birthMonth': birthMonth,
      if (birthDay != null) 'birthDay': birthDay,
      if (complete != null) 'complete': complete,
      if (field != null && value != null) field: value,
    });

    return (await get(uid))!;
  }

  /// If the user has completed the profile, set the complete field to true.
  Future<User> updateComplete(bool complete) async {
    return await update(complete: complete);
  }
}
