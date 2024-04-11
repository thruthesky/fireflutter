import 'package:firebase_database/firebase_database.dart';

import 'package:fireflutter/fireflutter.dart' as ff;
import 'package:geohash_plus/geohash_plus.dart';

class User {
  /// Paths and Refs
  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();

  static const String node = 'users';
  static DatabaseReference usersRef = rootRef.child('users');

  /// data paths
  static const String userProfilePhotos = 'user-profile-photos';
  static const String whoLikeMe = 'who-like-me';
  static const String whoILike = 'who-i-like';
  static const String mutualLike = 'mutual-like';

  static String user(String uid) => '$node/$uid';
  static String userField(String uid, String field) => '${user(uid)}/$field';

  /// 내가 다른 사람을 좋아요 할 때, 그 정보를 저장하는 노드 경로
  static String whoILikePath(String a, String b) => '$whoILike/$a/$b';

  static DatabaseReference iLikeRef(String b) =>
      FirebaseDatabase.instance.ref(whoILikePath(ff.myUid!, b));

  ///
  static DatabaseReference userRef(String uid) => usersRef.child(uid);
  static DatabaseReference userProfilePhotosRef =
      rootRef.child('profile-photos');
  static DatabaseReference whoILikeRef = rootRef.child(whoILike);
  static DatabaseReference whoLikeMeRef = rootRef.child(whoLikeMe);
  static DatabaseReference mutualLikeRef = rootRef.child(mutualLike);

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

  @Deprecated('email is a private informationn. Use UserPrivate')
  String email;
  @Deprecated('phoneNumber is a private informationn. Use UserPrivate')
  String phoneNumber;

  /// The primary photo URL of the user.
  String photoUrl;

  /// The background image URL of the user profile. This is used as the
  /// background image of the user profile.
  String profileBackgroundImageUrl;

  /// Extra photo URLs of the user. User can upload multiple photos of
  /// themselves.
  List<String> photoUrls;

  String stateMessage;

  /// 사용자가 비활성화 되었는지 여부
  bool isDisabled;
  bool get disabled => isDisabled;
  int birthYear;
  int birthMonth;
  int birthDay;
  int createdAt;
  int order;
  bool isAdmin;
  bool isVerified;
  List<String>? blocks;

  /// [gender] can be "M" or "F" or "".
  ///
  /// Use [isMale] to check if the user is male.
  ///
  /// Use [isFemale] to check if the user is female.
  String gender;

  bool get isMale => gender == 'M';
  bool get isFemale => gender == 'F';

  int noOfLikes;

  /// TODO @withcenter-dev2change this to countryCode
  @Deprecated('Change this to countryCode')
  String nationality;

  String siDo;
  String siGunGu;

  /// User's latitude and longitude
  double latitude;
  double longitude;

  /// When the user's location was updated, geohash data is also updated.
  ///
  ///
  /// [geohash3] is used for searching nearby users above 20k meters
  String geohash3;

  /// [geohash4] is used for searching nearby users within 20k meters
  String geohash4;

  /// [geohash5] is used for searching nearby users within 5k meters
  String geohash5;

  /// [geohash6] is used for searching nearby users within 1k meters
  String geohash6;

  /// [geohash7] is used for searching nearby users within 200 meters
  String geohash7;

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

  /// [ping] is an int value that is used to update user document.
  ///
  /// You can use this to trigger any listeners that are listening to the user
  /// document. Especially, when you use [MyDoc] widget, you can update this value
  /// to rebuild the widget.
  /// For example, when user pays, you can update this value to trigger the [MyDoc]
  /// widget to rebuild.
  int ping;

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

// user age by computing the current date  and the user given year and month and day
  String get age {
    if (birthDay == 0 || birthYear == 0 || birthYear == 0) return "";
    DateTime currentTime = DateTime.now();
    int age = currentTime.year - birthYear;
    if (currentTime.month < birthMonth ||
        (currentTime.month == birthMonth && currentTime.day < birthDay)) {
      age--;
    }
    return age.toString();
  }

  String occupation;
  String languageCode;

  User({
    required this.data,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.photoUrl,
    required this.profileBackgroundImageUrl,
    required this.photoUrls,
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
    required this.gender,
    required this.noOfLikes,
    required this.idUrl,
    required this.idUploadedAt,
    required this.occupation,
    required this.nationality,
    required this.siDo,
    required this.siGunGu,
    required this.latitude,
    required this.longitude,
    required this.geohash3,
    required this.geohash4,
    required this.geohash5,
    required this.geohash6,
    required this.geohash7,
    required this.languageCode,
    required this.ping,
  });

  factory User.fromSnapshot(DataSnapshot snapshot) {
    ///
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['uid'] = snapshot.key;
    return User.fromJson(json);
  }

  /// 사용자 uid 로 부터, User 을 만들어, 빈 User 을 리턴한다.
  ///
  /// 즉, 생성된 User 의 instance 에서, uid 를 제외한 모든 properties 는 null 이지만,
  /// uid 를 기반으로 하는, 각종 method 를 쓸 수 있다.
  ///
  /// 예를 들면, User.fromUid(uid).ref.child('photoUrl').onValue 등과 같이 쓸 수 있으며,
  /// update(), delete() 함수 등을 쓸 수 있다.
  ///
  /// 만약, uid 만으로 사용자 정보 전체를 다 가지고 싶다면,
  factory User.fromUid(String uid) {
    return User.fromJson({
      'uid': uid,
    });
  }

  factory User.fromJson(Map<dynamic, dynamic> json, {String? uid}) {
    return User(
      data: Map<String, dynamic>.from(json),
      uid: uid ?? json['uid'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      profileBackgroundImageUrl: json['profileBackgroundImageUrl'] ?? '',

      /// [photoUrls] is a list of photo urls.
      /// This code handles with the malformed photoUrl data.
      photoUrls: json['photoUrls'] is List
          ? List<String>.from(
              ((json['photoUrls'] ?? []) as List)
                  .map((x) => x.toString())
                  .toList(),
            )
          : [],
      //List<String>.from((json['photoUrls'] ?? [])),
      stateMessage: json['stateMessage'] ?? '',
      isDisabled: json['isDisabled'] ?? false,
      birthYear: json['birthYear'] ?? 0,
      birthMonth: json['birthMonth'] ?? 0,
      birthDay: json['birthDay'] ?? 0,
      gender: json['gender'] ?? '',
      noOfLikes: json['noOfLikes'] ?? 0,
      createdAt: json['createdAt'] ?? 0,
      order: json['order'] ?? 0,
      isAdmin: json['isAdmin'] ?? false,
      isVerified: json['isVerified'] ?? false,
      blocks: json[ff.Field.blocks] == null
          ? null
          : List<String>.from(
              (json[ff.Field.blocks] as Map<Object?, Object?>)
                  .entries
                  .map((x) => x.key),
            ),
      idUrl: json[ff.Field.idUrl] ?? '',
      idUploadedAt: json[ff.Field.idUploadedAt] ?? 0,
      occupation: json[ff.Field.occupation] ?? '',
      nationality: json['nationality'] ?? '',
      siDo: json['siDo'] ?? '',
      siGunGu: json['siGunGu'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      geohash3: json['geohash3'] ?? '',
      geohash4: json['geohash4'] ?? '',
      geohash5: json['geohash5'] ?? '',
      geohash6: json['geohash6'] ?? '',
      geohash7: json['geohash7'] ?? '',
      languageCode: json['languageCode'] ?? '',
      ping: json['ping'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'profileBackgroundImageUrl': profileBackgroundImageUrl,
      'photoUrls': photoUrls,
      'stateMessage': stateMessage,
      'isDisabled': isDisabled,
      'birthYear': birthYear,
      'birthMonth': birthMonth,
      'birthDay': birthDay,
      'gender': gender,
      'noOfLikes': noOfLikes,
      'createdAt': createdAt,
      'order': order,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
      ff.Field.blocks:
          blocks == null ? null : List<dynamic>.from(blocks!.map((x) => x)),
      ff.Field.idUrl: idUrl,
      ff.Field.idUploadedAt: idUploadedAt,
      ff.Field.occupation: occupation,
      'nationality': nationality,
      'siDo': siDo,
      'siGunGu': siGunGu,
      'latitude': latitude,
      'longitude': longitude,
      'geohash4': geohash4,
      'geohash5': geohash5,
      'geohash6': geohash6,
      'geohash7': geohash7,
      'languageCode': languageCode,
      'ping': ping,
    };
  }

  @override
  String toString() {
    return 'User(${toJson()})';
  }

  /// Reload user data and apply it to this instance.
  Future<User> reload() async {
    final user = await User.get(uid);

    if (user != null) {
      name = user.name;
      displayName = user.displayName;
      photoUrl = user.photoUrl;
      profileBackgroundImageUrl = user.profileBackgroundImageUrl;
      photoUrls = user.photoUrls;
      stateMessage = user.stateMessage;
      isDisabled = user.isDisabled;
      birthYear = user.birthYear;
      birthMonth = user.birthMonth;
      birthDay = user.birthDay;
      gender = user.gender;
      noOfLikes = user.noOfLikes;
      createdAt = user.createdAt;
      order = user.order;
      isAdmin = user.isAdmin;
      isVerified = user.isVerified;
      blocks = user.blocks;
      idUrl = user.idUrl;
      idUploadedAt = user.idUploadedAt;
      occupation = user.occupation;
      nationality = user.nationality;
      siDo = user.siDo;
      siGunGu = user.siGunGu;
      latitude = user.latitude;
      longitude = user.longitude;
      geohash3 = user.geohash3;
      geohash4 = user.geohash4;
      geohash5 = user.geohash5;
      geohash6 = user.geohash6;
      geohash7 = user.geohash7;
      languageCode = user.languageCode;
      ping = user.ping;
    }

    return this;
  }

  bool blocked(String otherUserUid) => isBlocked(otherUserUid);

  /// 사용자 정보 node 전체를 User 에 담아 리턴한다.
  static Future<User?> get(String uid) async {
    try {
      final nodeData = await ff.get<Map<dynamic, dynamic>>('users/$uid');
      if (nodeData == null) {
        return null;
      }

      nodeData['uid'] = uid;
      return User.fromJson(nodeData);
    } catch (e) {
      print('---> User.get($uid) error: $e');
      rethrow;
    }
  }

  /// 입력된 전화번호 문자열을 바탕으로 사용자 정보(문서, 값)를 찾아 사용자 모델로 리턴한다.
  // static Future<User?> getByPhoneNumber(String phoneNumber) async {
  //   final snapshot =
  //       await Ref.users.orderByChild('phoneNumber').equalTo(phoneNumber).get();

  //   if (snapshot.value == null) {
  //     return null;
  //   }
  //   return null;
  // }

  /// 사용자의 특정 필만 가져와서 리턴한다.
  ///
  /// ```dart
  /// User.getField(uid, ff.Field.isVerified);
  /// ```
  static Future<T?> getField<T>(String uid, String field) async {
    final nodeData = await ff.get('users/$uid/$field');
    if (nodeData == null) {
      return null;
    }

    return nodeData as T;
  }

  /// Create user document
  ///
  /// This returns User of the created user document.
  static Future<User> create({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    await ff.set(
      '${ff.User.node}/$uid',
      {
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': ServerValue.timestamp,
        'order': DateTime.now().millisecondsSinceEpoch * -1,
      },
    );

    final created = await User.get(uid);
    ff.UserService.instance.onCreate?.call(created!);
    return created!;
  }

  /// Update user data.
  ///
  /// All user data fields must be updated with this method.
  ///
  /// hasPhotoUrl is automatically set to true if photoUrl is not null.
  ///
  /// [photoUrl] 값이 빈 문자열이면, 해당 필드는 삭제되고, hasPhotoUrl 도 false 로 저장된다.
  ///
  /// Note that, this method does not update user's private information like
  /// email, phone number, etc. It only updates public information like
  /// displayName, photoUrl, etc.
  Future<User> update({
    String? name,
    String? displayName,
    String? photoUrl,
    String? profileBackgroundImageUrl,
    List<String>? photoUrls,
    String? stateMessage,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    String? gender,
    bool? isAdmin,
    bool? isVerified,
    dynamic createdAt,
    dynamic order,
    int? idUploadedAt,
    String? idUrl,
    String? occupation,
    String? nationality,
    String? siDo,
    String? siGunGu,
    double? latitude,
    double? longitude,
    String? languageCode,
    int? ping,
  }) async {
    final data = {
      if (name != null) 'name': name,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (profileBackgroundImageUrl != null)
        'profileBackgroundImageUrl': profileBackgroundImageUrl,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (stateMessage != null) 'stateMessage': stateMessage,
      if (photoUrl != null) 'hasPhotoUrl': true,
      if (birthYear != null) 'birthYear': birthYear,
      if (birthMonth != null) 'birthMonth': birthMonth,
      if (birthDay != null) 'birthDay': birthDay,
      if (gender != null) 'gender': gender,
      if (isAdmin != null) 'isAdmin': isAdmin,
      if (isVerified != null) 'isVerified': isVerified,
      if (createdAt != null) 'createdAt': createdAt,
      if (order != null) 'order': order,
      if (idUploadedAt != null) 'idUploadedAt': idUploadedAt,
      if (idUrl != null) 'idUrl': idUrl,
      if (occupation != null) ff.Field.occupation: occupation,
      if (nationality != null) 'nationality': nationality,
      if (siDo != null) 'siDo': siDo,
      if (siGunGu != null) 'siGunGu': siGunGu,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (languageCode != null) 'languageCode': languageCode,
      if (ping != null) 'ping': ping,
    };
    if (data.isEmpty) {
      return this;
    }

    if (latitude != null && longitude != null) {
      final geohash = GeoHash.encode(latitude, longitude);
      final hash = geohash.hash;
      data['geohash3'] = hash.substring(0, 3);
      data['geohash4'] = hash.substring(0, 4);
      data['geohash5'] = hash.substring(0, 5);
      data['geohash6'] = hash.substring(0, 6);
      data['geohash7'] = hash.substring(0, 7);
    }

    // 업데이트부터 하고
    await ff.update(
      'users/$uid',
      data,
    );

    /// 사용자 객체(User) 를 reload 하고, (주의: 로그인한 사용자의 정보가 아닐 수 있다.)
    await reload();
    // final updated = await User.get(uid);

    /// 사진 정보 업데이트
    if (displayName != null || photoUrl != null) {
      await _updateUserProfilePhotos(
          displayName: displayName, photoUrl: photoUrl);
    }

    ff.UserService.instance.onUpdate?.call(this);
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
        if (photoUrl != null) ff.Field.photoUrl: photoUrl,
        if (displayName != null) ff.Field.displayName: displayName,
        if (photoUrl != null)
          ff.Field.updatedAt: DateTime.now().millisecondsSinceEpoch * -1,
      });
    }
  }

  /// Delete user data.
  ///
  /// update() 메소드에 필드를 null 로 주면, 해당 필드가 삭제되지 않고 그냐 그대로 유지된다.
  /// 그래서, delete() 메소드를 따로 만들어서 사용한다.
  Future<void> deletePhotoUrl() async {
    await ff.update(
      'users/$uid',
      {
        ff.Field.photoUrl: null,
        ff.Field.hasPhotoUrl: false,
      },
    );

    await photoRef.remove();
  }

  /// 인증 완료 설정
  ///
  /// 관리자가 수동으로 신분증을 인증하면, 해당 사용자는 완전히 인증된 것이다.
  Future<void> setVerified() async {
    await ref.update({
      ff.Field.isVerified: true,
      ff.Field.idUploadedAt: null,
    });
  }

  /// 인증 취소
  ///
  /// 해당 사용자는 인증 대기 목록에 표시된다.
  Future<void> setUnverified() async {
    await ref.update({
      ff.Field.isVerified: null,
      ff.Field.idUploadedAt: DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 신분증 업로드
  Future<User> setVerificationIdUrl(String url) async {
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
      ff.Field.idUrl: null,
      ff.Field.idUploadedAt: null,
    });
  }

  /// Blocks or unblocks
  ///
  /// After this method call, the user is blocked or unblocked.
  /// Returns true if the user has just blocked blocked, false if unblocked.
  ///
  Future block(String otherUserUid) async {
    if (otherUserUid == uid) {
      throw ff.Issue(ff.Code.blockSelf, 'You cannot block yourself.');
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
    return await ref.child(ff.Field.blocks).child(otherUserUid).set(
          ServerValue.timestamp,
        );
  }

  /// Unblock a user
  ///
  /// Remove the user from the block list by setting null value
  Future unblockUser(String otherUserUid) async {
    return await ref.child(ff.Field.blocks).child(otherUserUid).set(null);
  }

  /// Like other user
  ///
  /// This method does both of the like and the unlike. If it is already liked, it will be unliked.
  /// And this method also records for mutual likes.
  ///
  /// Returns true if the user has just liked, false if unliked.
  ///
  Future like(String otherUserUid) async {
    final re = await ff.toggle(
      path: ff.User.whoILikePath(ff.my!.uid, otherUserUid),
    );
    ff.ActivityLog.userLike(otherUserUid, re);

    /// Mutual like
    if (re) {
      /// The login user liked the other user.
      final got = await whoLikeMeRef.child(ff.myUid!).child(otherUserUid).get();
      if (got.exists) {
        /// it's mutual like
        await mutualLikeRef
            .child(ff.myUid!)
            .child(otherUserUid)
            .set(ServerValue.timestamp);
        await mutualLikeRef
            .child(otherUserUid)
            .child(ff.myUid!)
            .set(ServerValue.timestamp);
      }
    } else {
      /// The login user unliked the other user.
      /// Remove mutual likes
      await mutualLikeRef.child(ff.myUid!).child(otherUserUid).remove();
      await mutualLikeRef.child(otherUserUid).child(ff.myUid!).remove();
    }

    ///
    return re;
  }
}
