import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:fireflutter/fireflutter.dart';
import 'package:rxdart/subjects.dart';

///
class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ?? (_instance = UserService());

  /// 현재 로그인한 사용자의 사용자 문서 모델. 서버에서 변경 될 때 마다 업데이트하고, 이벤트 발생.
  UserModel user = UserModel();
  StreamSubscription? userDocumentSubscription;
  BehaviorSubject userChange = BehaviorSubject.seeded(UserModel());
  UserSettingsModel? settings;
  String? get displayName => user.displayName;

  CollectionReference get col => FirebaseFirestore.instance.collection('users');
  DocumentReference get doc =>
      col.doc(Firebase.FirebaseAuth.instance.currentUser?.uid);

  @Deprecated('Use return UserService.instance.get(uid);')
  Future<UserModel> getOtherUserDoc(
    String uid, {
    bool reset = false,
  }) async {
    assert(uid != '');

    return UserService.instance.get(uid);
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

  /// 사용자 문서가 업데이트되면, 이벤트를 발생시킨다.
  observeUserDoc() {
    userDocumentSubscription?.cancel();
    userDocumentSubscription =
        doc.snapshots().listen((DocumentSnapshot snapshot) async {
      user = UserModel.fromSnapshot(snapshot);
      print('----> observeUserDoc $user');
      userChange.add(user);
    });
  }

  create() {}

  /// `/users/<uid>` 문서를 읽어 UserModel 로 리턴한다.
  /// 해당 문서가 존재하지 않으면 속성이 빈 값이 된다.
  Future<UserModel> get(String uid) async {
    final snapshot = await col.doc(uid).get();
    return UserModel.fromSnapshot(snapshot);
  }

  /// 문서가 존재하지 않으면 생성을 한다.
  Future<void> update(Map<String, dynamic> data) {
    return doc.set({
      ...data,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  delete() {}

  Future<UserModel> blockUser(String uid) async {
    UserModel user = await UserService.instance.get(uid);

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
    UserModel user = await UserService.instance.get(uid);

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
