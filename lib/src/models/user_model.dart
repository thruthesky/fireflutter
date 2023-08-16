import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  static const String collectionName = 'users';

  final String uid;

  /// 만약, dsiplayName 이 없으면, uid 의 앞 두글자를 대문자로 표시.
  final String displayName;
  final String name;
  final String photoUrl;
  final String phoneNumber;
  final String email;

  /// DB 에 저장되는 값. 그래야 검색이 가능.
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
  final bool exists;

  User({
    required this.uid,
    this.displayName = '',
    this.name = '',
    this.photoUrl = '',
    this.hasPhotoUrl = false,
    this.phoneNumber = '',
    this.email = '',
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
      displayName: displayName == '' ? id.toUpperCase().substring(0, 2) : displayName,
      name: map['name'] ?? '',
      photoUrl: (map['photoUrl'] ?? '') as String,
      hasPhotoUrl: map['hasPhotoUrl'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'],
      complete: map['complete'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'name': name,
      'photoUrl': photoUrl,
      'hasPhotoUrl': hasPhotoUrl,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'complete': complete,
    };
  }

  @override
  String toString() =>
      '''User(uid: $uid, name: $name, displayName: $displayName, photoUrl: $photoUrl, hasPhotoUrl: $hasPhotoUrl, phoneNumber: $phoneNumber, email: $email, createdAt: $createdAt, createdAtDateTime: $createdAtDateTime, complete: $complete, exists: $exists)''';

  /// 사용자 문서를 읽어온다.
  ///
  /// 사용자 문서가 존재하지 않는 경우, null 을 리턴한다.
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
    String? displayName,
    String? photoUrl,
    bool? hasPhotoUrl,
    String? phoneNumber,
    String? email,
    bool? complete,
    String? field,
    dynamic value,
  }) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(uid);

    await doc.update({
      if (name != null) 'name': name,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (hasPhotoUrl != null) 'hasPhotoUrl': hasPhotoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (complete != null) 'complete': complete,
      if (field != null && value != null) field: value,
    });

    return (await get(uid))!;
  }
}
