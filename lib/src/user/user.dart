import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:fireflutter/fireflutter.dart';

class User {
  static User? _instance;
  static User get instance => _instance ?? (_instance = User());

  /// 사용자 정보를 미리 로드하지 않는다. README.md 참고
  @Deprecated('Use MyDoc(). Do not load user data beforehand.')
  UserModel? data;
  UserSettingsModel? settings;
  String? get displayName => data?.displayName;

  CollectionReference get col => FirebaseFirestore.instance.collection('users');
  DocumentReference get doc =>
      col.doc(Firebase.FirebaseAuth.instance.currentUser?.uid);

  @Deprecated('Use return User.instance.get(uid);')
  Future<UserModel> getOtherUserDoc(
    String uid, {
    bool reset = false,
  }) async {
    assert(uid != '');

    return User.instance.get(uid);
  }

  /// TODO check if the user is admin
  bool get isAdmin => false;

  bool get notSignedIn =>
      isAnonymous || Firebase.FirebaseAuth.instance.currentUser == null;

  bool get signedIn => !notSignedIn;
  bool get isAnonymous =>
      Firebase.FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  String? get phoneNumber =>
      Firebase.FirebaseAuth.instance.currentUser?.phoneNumber;

  /// ^ Even if anonymously-sign-in enabled, it still needs to be nullable.
  /// ! To avoid `null check operator` problem in the future.
  String? get uid => Firebase.FirebaseAuth.instance.currentUser?.uid;

  create() {}

  /// `/users/<uid>` 문서를 읽어 UserModel 로 리턴한다.
  /// 해당 문서가 존재하지 않으면 속성이 빈 값이 된다.
  Future<UserModel> get(String uid) async {
    final snapshot = await col.doc(uid).get();
    return UserModel.fromSnapshot(snapshot);
  }

  Future<void> update(Map<String, dynamic> data) {
    return doc.set({
      ...data,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  delete() {}

  Future<UserModel> blockUser(String uid) async {
    UserModel user = await User.instance.get(uid);

    /// TODO block user by admin
    ///
    // if (user.disabled) throw ERROR_USER_ALREADY_BLOCKED;

    // final res = await FunctionsApi.instance
    //     .request('adminDisableUser', data: {'userUid': uid}, addAuth: true);
    // UserModel u = UserModel.fromJson(res, uid);
    // if (u.disabled) others[uid]!.disabled = u.disabled;
    // return others[uid]!;

    return user;
  }

  Future<UserModel> unblockUser(String uid) async {
    UserModel user = await User.instance.get(uid);

    /// TODO unblock user by admin
    ///
    // if (!user.disabled) throw ERROR_USER_ALREADY_UNBLOCKED;

    // final res = await FunctionsApi.instance
    //     .request('adminEnableUser', data: {'userUid': uid}, addAuth: true);
    // UserModel u = UserModel.fromJson(res, uid);
    // if (u.disabled == false) others[uid]!.disabled = u.disabled;
    // return others[uid]!;

    return user;
  }

  signOut() async {
    /// Don't update() here. update() will be made on authStateChanges()
    await Firebase.FirebaseAuth.instance.signOut();
  }

  /// 입력된 전화번호가 이미 가입되어져 있으면 참을 리턴한다.
  /// 전화번호 로그인을 할 때, 만약 전화번호가 이미 가입되어져 있으면, 그 전화번호로 로그인을 하고 아니면, 새로 생성하는데, 이 때, Anonymous 계정과 합친다.
  /// 이 기능은 클라이언트에서는 안되고, 반드시 cloud 함수로 해야 만 한다.
  Future<bool> phoneNumberExists(String phoneNumber) async {
    /// TODO 사용자 전화번호가 이미 가입되어져 있으면 참을 리턴한다.
    // final res = await FunctionsApi.instance.request(
    //   FunctionName.userByPhoneNumberExists,
    //   data: {'phoneNumber': phoneNumber},
    // );
    // print('---------> res; $res');
    // return res['result'];

    return false;
  }

  bool isOtherUserDisabled(String uid) {
    /// TODO check if other user is disabled.
    return false;
    // if (others[uid] == null) return false;
    // return others[uid]!.disabled;
  }

  bool isOtherUserNotDisabled(String uid) {
    /// TODO check if other user is not disabled.
    return false;
    // return !isOtherUserDisabled(uid);
  }
}
