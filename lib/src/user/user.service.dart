import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  // UserSettingsModel? settings;
  String get displayName => user.displayName;
  String get shortDisplayName => user.shortDisplayName;

  CollectionReference get col => FirebaseFirestore.instance.collection('users');
  DocumentReference get doc => col.doc(Firebase.FirebaseAuth.instance.currentUser?.uid);

  DocumentReference get pointDoc => doc.collection('user_meta').doc('point');

  CollectionReference get pointHistoryCol => doc.collection('point_history');

  /// 사용자 설정 관련 코드
  UserSettings settings = UserSettings();

  bool get isAdmin => user.admin;

  /// Return true if the user didn't sigend at all, even as anonymous.
  bool get notSignedInAtAll => Firebase.FirebaseAuth.instance.currentUser == null;

  /// Return true if the user signed with real account. Not anonymous.
  bool get notSignedIn => isAnonymous || Firebase.FirebaseAuth.instance.currentUser == null;

  bool get signedIn => !notSignedIn;
  bool get isAnonymous => Firebase.FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  String? get phoneNumber => Firebase.FirebaseAuth.instance.currentUser?.phoneNumber;

  /// ^ Even if anonymously-sign-in enabled, it still needs to be nullable.
  /// ! To avoid `null check operator` problem in the future.
  String? get uid => Firebase.FirebaseAuth.instance.currentUser?.uid;

  /// 사용자 문서가 업데이트되면, 이벤트를 발생시킨다.
  /// 주의, Anonymous 사용자로 로그인하는 경우는 이 함수가 호출되지 않는다.
  /// 그리고, Anonymous 로 로그인하는 경우, unobserverUserDoc() 을 통해서 MyDoc() 이 한번 호출된다.
  observeUserDoc() {
    userDocumentSubscription?.cancel();
    userDocumentSubscription = doc.snapshots().listen((DocumentSnapshot snapshot) async {
      if (snapshot.exists == false) {
        // log('---> User document not exits in observeUserDoc.');
      }
      user = UserModel.fromSnapshot(snapshot);
      // log('----> observeUserDoc and update event with; $user');
      userChange.add(user);
    });
  }

  /// 로그아웃을 할 때 호출되며, 사용자 모델(user)을 초기화하고, listening 해제하고, 이벤트를 날린다.
  unobserveUserDoc() {
    userDocumentSubscription?.cancel();
    user = UserModel();
    userChange.add(user);
  }

  /// `/users/<uid>` 문서를 읽어 UserModel 로 리턴한다.
  ///
  /// 해당 문서가 존재하지 않으면 속성이 빈 값이 된다.
  ///
  /// 참고, 이 함수는 읽은 사용자 문서를 메모리 캐시를 한다. 즉, (비용 절감을 위해서) Firestore 에서 한번만 읽고 두 번 읽지 않는다.
  /// 만약 [cache] 가 false 이면, Firestore 로 부터 문서를 읽는다. 즉, refresh 한다.
  Map<String, UserModel> userDocumentContainer = {};
  Future<UserModel> get(
    String uid, {
    bool cache = true,
  }) async {
    if (cache == true && userDocumentContainer[uid] != null) {
      return userDocumentContainer[uid]!;
    }
    final snapshot = await col.doc(uid).get();
    userDocumentContainer[uid] = UserModel.fromSnapshot(snapshot);
    return userDocumentContainer[uid]!;
  }

  /// 문서가 존재하지 않으면 생성을 한다.
  Future<void> update(Map<String, dynamic> data) {
    return doc.set({
      ...data,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<UserModel> blockUser(String uid) async {
    UserModel user = await UserService.instance.get(uid);
    if (user.disabled) throw ERROR_USER_ALREADY_BLOCKED;
    try {
      final res = await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
          .httpsCallable('disableUser')
          .call({'uid': uid});
      log(res.toString());

      return await this.get(uid, cache: false);
    } on FirebaseFunctionsException catch (e) {
      log('Exception from callable function in UserService.instance.blockUser()');
      log(e.code);
      log(e.details);
      log(e.message.toString());
      rethrow;
    }
  }

  Future<UserModel> unblockUser(String uid) async {
    UserModel user = await UserService.instance.get(uid);
    if (user.disabled == false) throw ERROR_USER_NOT_BLOCKED;
    try {
      final res =
          await FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('enableUser').call({'uid': uid});
      log(res.toString());

      return await this.get(uid, cache: false);
    } on FirebaseFunctionsException catch (e) {
      log('Exception from callable function in UserService.instance.unblockUser()');
      log(e.code);
      log(e.details);
      log(e.message.toString());
      rethrow;
    }
  }

  signOut() async {
    /// Don't update() here. update() will be made on authStateChanges()
    await Firebase.FirebaseAuth.instance.signOut();
  }

  /// 서버(또는 캐시된 데이터)로 부터 사용자 정보를 가져와서, 사용자 계정이 블럭되었는지 표시하는 disabled 속성 값을
  /// 확인해서, true 이면, disabled (블럭) 된 것이며 true 를 리턴한다.
  ///
  /// 서버로 부터 값을 확인하므로 Future<bool> 을 리턴한다.
  ///
  /// Returns true if the user of the uid is disabled.
  Future<bool> checkDisabled(String uid) async {
    UserModel user = await UserService.instance.get(uid);
    return user.disabled;
  }

  /// Returns true if the user is not disabled.
  Future<bool> checkEnabled(String uid) async {
    final re = await this.checkDisabled(uid);
    return !re;
  }

  /// 사용자가 블럭되었는지 확인을 한다.
  ///
  /// 주의, 이 함수는 서버로 부터 사용자 문서를 가져오지 않고, 캐시된 것만 사용한다. 따라서 Future 가 아닌 그냥
  /// bool 을 리턴하는데, 사용자 정보를 가져오지 않은 경우, 실제로 블럭되어져 있어도 false 를 리턴하므로 주의한다.
  ///
  /// 이 함수는 메모리에 사용자 문서가 캐시되었다는 확신이 있을 때에만 사용해야 한다.
  /// 참고로, 사용자 문서를 서버로 부터 가져 올 때, 기본적으로 메모리 캐시를 한다.
  ///
  bool isBlocked(String uid) {
    if (UserService.instance.userDocumentContainer[uid] == null) {
      return false;
    } else {
      return UserService.instance.userDocumentContainer[uid]!.disabled;
    }
  }

  /// 사용자가 블럭되지 않았으면 true 를 리턴. 주의, 사용자 정보가 미리, 메모리 캐시되어 있어야 한다.
  bool isNotBlocked(String uid) {
    return !this.isBlocked(uid);
  }
}
