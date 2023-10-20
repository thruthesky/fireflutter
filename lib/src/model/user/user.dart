import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/activity_log.functions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  static const String collectionName = 'users';

  /// '/users' collection
  static CollectionReference col = FirebaseFirestore.instance.collection(collectionName);

  /// '/users/{uid}' document.
  ///
  /// Example
  /// ```dart
  /// User.doc('xxx').update({...});
  /// ```
  static DocumentReference doc(String uid) => col.doc(uid);

  /// This holds the original JSON document data of the user document. This is
  /// useful when you want to save custom data in the user document.
  @JsonKey(includeFromJson: false, includeToJson: false)
  late Map<String, dynamic> data;

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
  final bool isVerified;

  ///
  final String phoneNumber;
  final String email;

  /// User state. It's like user's status or mood, motto. You can save whatever here.
  /// 상태. 개인의 상태, 무드, 인사말 등. 예를 들어, 휴가중. 또는 모토. 인생은 모험이 아니면 아무것도 아닙니다.
  final String state;

  /// User state image (or public profile title image).
  ///
  /// Use this for any purpose to display user's current state. Good example of
  /// using this is to display user's public profile title image.
  final String stateImageUrl;

  final int birthYear;
  final int birthMonth;
  final int birthDay;
  final int birthDayOfYear;

  final String gender;

  final int noOfPosts;
  final int noOfComments;

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

  /// Since we removed easy-extension, We don't know when the document is being created.
  /// Check user document creation time in UserService and if there is not [createdAt], add one.
  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  /// Gets the birthdate using the birthYear, birthMonth, and birthDay of the user
  DateTime get birthdate => DateTime(birthYear, birthMonth, birthDay);

  /// Gets the age of the user
  int? get age => birthYear != 0 ? DateTime.now().difference(birthdate).inDays ~/ 365 : null;

  /// Set this to true when the user has completed the profile.
  /// This should be set when the user submit the profile form.
  ///
  /// 사용자가 회원 정보를 업데이트 할 때, 이 값을 true 또는 false 로 지정한다.
  /// 이 값이 false 이면, 앱에서 회원 정보를 입력하라는 메시지를 표시하거나 기타 동작을 하게 할 수 있다.
  final bool isComplete;

  final List<String> followers;
  final List<String> followings;

  bool cached;

  /// Likes
  final List<String> likes;

  /// disabled user
  final bool isDisabled;

  @JsonKey(includeFromJson: false, includeToJson: true)
  bool exists = true;

  final List<String> blockedUsers;

  /// Returns the user's display name. If the display name is empty, it will
  /// return the name. If the name is empty, it will return the uid.
  String get getDisplayName {
    return displayName.isNotEmpty
        ? displayName
        : name.isNotEmpty
            ? name
            : firstName.isNotEmpty
                ? firstName
                : lastName.isNotEmpty
                    ? lastName
                    : 'No name';
  }

  User({
    this.uid = '',
    this.isAdmin = false,
    this.displayName = '',
    this.name = '',
    this.firstName = '',
    this.lastName = '',
    this.middleName = '',
    this.photoUrl = '',
    this.hasPhotoUrl = false,
    this.idVerifiedCode = '',
    this.isVerified = false,
    this.phoneNumber = '',
    this.email = '',
    this.state = '',
    this.stateImageUrl = '',
    this.birthYear = 0,
    this.birthMonth = 0,
    this.birthDay = 0,
    this.birthDayOfYear = 0,
    this.gender = '',
    this.type = '',
    this.isComplete = false,
    this.noOfPosts = 0,
    this.noOfComments = 0,
    this.followers = const [],
    this.followings = const [],
    this.cached = false,
    this.likes = const [],
    this.isDisabled = false,
    this.blockedUsers = const [],
    required this.createdAt,
  });

  // factory User.notExists({String uid = ''}) {
  //   return User(uid: uid, exists: false, createdAt: DateTime.now());
  // }

  /// Returns a user with uid. All other properties are empty.
  ///
  ///
  factory User.fromUid(String uid) {
    return User(uid: uid, createdAt: DateTime(1970));
  }

  // Use this to create a user model object indicating that the user document does not exist.
  factory User.nonExistent() {
    return User(uid: '', createdAt: DateTime(1970))..exists = false;
  }

  factory User.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return User.fromJson({
      ...(documentSnapshot.data() ?? Map<String, dynamic>.from({})) as Map<String, dynamic>,
      'uid': documentSnapshot.id,
    });
  }

  ///
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json)..data = json;

  Map<String, dynamic> toMap() {
    return _$UserToJson(this);
  }

  @override
  String toString() => '''User(${toMap().toString().replaceAll('\n', '')}})''';

  /// Get user document
  ///
  /// If the user document does not exist, it will return null. It does not throw an exception.
  /// But if the uid is wrong, then it would throw a permission denied exception. since the security rules fails.
  ///
  /// [uid] is the user's uid. If it's null, it will get the login user's document.
  ///
  /// Note, that It gets data from /users collections. It does not get data from /search-user-data collection.
  static Future<User?> get([String? userUid]) async {
    /// If the userUid is null, then get the login user's document.
    final snapshot = await FirebaseFirestore.instance.collection(collectionName).doc(userUid ?? myUid).get();
    if (snapshot.exists == false || snapshot.data() == null) return null;
    return User.fromDocumentSnapshot(snapshot);
  }

  /// Create user document.
  ///
  /// Note, it creates the document if it does not exists. If it exists, it will update.
  ///
  /// 사용자 문서가 이미 존재하는 경우, 문서를 덮어쓰지 않고, 업데이트한다.
  ///
  /// FirebaseAuth 에 먼저 로그인을 한 후, 함수를 호출해야 Security rules 를 통과 할 수 있다.
  ///
  /// Note that, the user document may be created by cloud function and the app
  /// may not call this method to create user document. In that case, the
  /// [onCreate] event handler will not be invoked.
  ///
  /// For security reason, don't put private information like email, phoneNumber, etc...
  ///
  /// See: README.md
  ///
  /// Example;
  /// ```dart
  /// User.create(uid: 'xxx');
  /// ```
  ///
  /// Logic of first login
  /// UserService.init() -> firebase authStateChanges() -> _listenUserDocument() -> User.create()
  static Future<User> create({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    await userDoc(uid).set({
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final createdUser = (await get(uid))!;

    UserService.instance.onCreate?.call(createdUser);

    /// log new user
    activityLogUserCreate();

    return createdUser;
  }

  /// Update user document
  ///
  /// Update the user document under /users/{uid} NOT only for the login user
  /// but also other user document as long as the permission allows.
  ///
  /// To update other user's data, you may use "User.fromUid().update(...)".
  ///
  /// Note that, It does not return the updated user document.
  ///
  /// Note, It create the document if it does not exists.
  ///
  /// Example
  /// ```dart
  /// User.fromUid('abc').update({ ... });
  /// my.update( noOfPosts: FieldValue.increment(1) ); // when UserService.instance.init() is called
  /// User.fromUid(FirebaseAuth.instance.currentUser!.uid).update( noOfPosts: FieldValue.increment(1) ); // when UserService.instance.init() is not called
  /// ```
  ///
  ///
  Future<void> update({
    String? name,
    String? firstName,
    String? lastName,
    String? middleName,
    String? displayName,
    String? photoUrl,
    bool? hasPhotoUrl,
    String? idVerifiedCode,
    // bool? isVerified,
    String? phoneNumber,
    String? email,
    String? state,
    String? stateImageUrl,
    int? birthYear,
    int? birthMonth,
    int? birthDay,
    String? gender,
    FieldValue? noOfPosts,
    FieldValue? noOfComments,
    String? type,
    bool? isComplete,
    FieldValue? followings,
    FieldValue? followers,
    FieldValue? likes,
    String? field,
    dynamic value,
    bool? isDisabled,
    FieldValue? blockedUsers,
    Map<String, dynamic> data = const {},
  }) async {
    final docData = {
      ...{
        if (name != null) 'name': name,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (middleName != null) 'middleName': middleName,
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (hasPhotoUrl != null) 'hasPhotoUrl': hasPhotoUrl,
        if (idVerifiedCode != null) 'idVerifiedCode': idVerifiedCode,
        // if (isVerified != null) 'isVerified': isVerified,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (email != null) 'email': email,
        if (state != null) 'state': state,
        if (stateImageUrl != null) 'stateImageUrl': stateImageUrl,
        if (birthYear != null) 'birthYear': birthYear,
        if (birthMonth != null) 'birthMonth': birthMonth,
        if (birthDay != null) 'birthDay': birthDay,
        if (gender != null) 'gender': gender,
        if (noOfPosts != null) 'noOfPosts': noOfPosts,
        if (noOfComments != null) 'noOfComments': noOfComments,
        if (type != null) 'type': type,
        if (isComplete != null) 'isComplete': isComplete,
        if (followings != null) 'followings': followings,
        if (followers != null) 'followers': followers,
        if (likes != null) 'likes': likes,
        if (field != null && value != null) field: value,
        if (isDisabled != null) 'isDisabled': isDisabled,
        if (blockedUsers != null) 'blockedUsers': blockedUsers,
      },
      ...data
    };

    /// Update the birth day of year
    if (docData['birthYear'] != null && docData['birthMonth'] != null && docData['birthDay'] != null) {
      final date = DateTime(docData['birthYear'], docData['birthMonth'], docData['birthDay']);
      docData['birthDayOfYear'] = date.difference(DateTime(date.year)).inDays + 1;
    }
    dog("User.update(); me: $myUid, who: $uid, path: ${userDoc(uid).path}, docData: $docData");

    // This is the code that actually updates the user document in DB.
    await userDoc(uid).set(
      docData,
      SetOptions(merge: true),
    );

    /// Get real data from the server. Assembling the user updated object won't work due to FieldValues.
    if (UserService.instance.onUpdate != null) {
      get(uid).then((user) => UserService.instance.onUpdate!(user!));
    }
    // /// log user update but this might not be necessary.
    // get(uid).then((user) {
    //   if (UserService.instance.onUpdate != null) {
    //     UserService.instance.onUpdate!(user!);
    //   }

    //   /// log user update
    //   ActivityService.instance.onUserUpdate(user!);
    // });
  }

  /// If the user has completed the profile, set the isComplete field to true.
  Future<void> updateComplete(bool isComplete) async {
    // This is to prevent unnecessary update.
    // Since firestore will count it as a write operation,
    // whether there are changes or none, it's better to prevent it.
    // https://cloud.google.com/firestore/pricing
    if (isComplete == this.isComplete) return;
    // This might be safer to prevent recursive loop.
    // rather than using update() method.
    await userDoc(uid).set(
      {'isComplete': isComplete},
      SetOptions(merge: true),
    );
  }

  /// Follow
  ///
  /// See README for details
  ///
  /// Returns true if followed a user. Returns false if unfollowed a user.
  ///
  /// Example
  /// ```dart
  /// final User me = await UserService.instance.get(myUid!, reload: true) as User;
  /// final re = await me.follow(otherUid);
  /// ```
  ///
  /// ! This method does not update the feed. It only updates `followings` and `followers` fields.
  /// ! Use [FeedService.instance.follow] to update with feed.
  Future<bool> follow(String otherUid) async {
    late bool isFollow;
    if (followings.contains(otherUid)) {
      await update(
        followings: FieldValue.arrayRemove([otherUid]),
      );
      await userDoc(otherUid).set({
        'followers': FieldValue.arrayRemove([myUid])
      }, SetOptions(merge: true));

      isFollow = false;
    } else {
      await update(
        followings: FieldValue.arrayUnion([otherUid]),
      );
      await userDoc(otherUid).set({
        'followers': FieldValue.arrayUnion([myUid])
      }, SetOptions(merge: true));
      isFollow = true;
    }

    /// log user follow/unfollow
    activityLogUserFollow(otherUid: otherUid, isFollow: isFollow);

    return isFollow;
  }

  /// Likes
  ///
  /// I am the one who likes other users.
  ///
  /// See README for details
  ///
  /// Returns true if liked a user. Returns false if unliked a user.
  ///
  /// Put the uid of the User to be liked in the [uid] parameter.
  Future<bool> like(String uid) async {
    bool isLiked = await toggle(pathUserLiked(uid));

    UserService.instance.sendNotificationOnLike(this, isLiked);
    UserService.instance.onLike?.call(this, isLiked);

    /// log user like/unlike
    activityLogUserLike(otherUid: uid, isLiked: isLiked);

    return isLiked;
  }

  /// Deletes the user document of current object.
  ///
  /// Instead of deleting the user document, it will set with {deleted: true}.
  Future delete() async {
    await userDoc(uid).set({'deleted': true});
    await myPrivateDoc.set({'deleted': true});
    UserService.instance.onDelete?.call(this);
  }

  /// Use this to block this user.
  Future<void> block(String otherUid) async {
    // Logged out user can't block.
    // I can't block myself.
    if (myUid == null || otherUid == myUid) return;
    await update(blockedUsers: FieldValue.arrayUnion([otherUid]));
  }

  /// Use this to block this user.
  Future<void> unblock(String otherUid) async {
    // Logged out user can't block.
    // I can't block myself.
    if (myUid == null || otherUid == myUid) return;
    await update(blockedUsers: FieldValue.arrayRemove([otherUid]));
  }

  /// check if user blocks the other user
  bool hasBlocked(String otherUid) {
    return blockedUsers.contains(otherUid);
  }

  /// Alias of [hasBlocked]
  bool haveBlocked(String otherUid) {
    return hasBlocked(otherUid);
  }

  /// Used by admin to disable users
  Future disable() async {
    await update(isDisabled: true);
  }

  /// Used by admin to revert disabling users
  Future enable() async {
    await update(isDisabled: false);
  }
}
