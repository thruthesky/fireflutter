import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  /// DB 에서 사용자 문서가 업데이트되면, 자동으로 이 변수에 sync 된다.
  UserModel? user;
  final rtdb = FirebaseDatabase.instance.ref();
  DatabaseReference get userRef => rtdb.child('users');
  DatabaseReference get myRef => userRef.child(myUid!);
  DatabaseReference get mySettingsRef => rtdb.child('user-settings');
  DatabaseReference otherSettingsRef(String uid, {String? path}) {
    if (path == null) {
      return rtdb.child('user-settings/$uid');
    } else {
      return rtdb.child('user-settings/$uid/$path');
    }
  }

  BehaviorSubject<UserModel?> myDataChanges =
      BehaviorSubject<UserModel?>.seeded(null);

  StreamSubscription? userNodeSubscription;

  UserCustomize customize = UserCustomize();

  Function(User user)? onSignout;

  bool enableNoOfProfileView = false;

  /// If [enableMessagingOnPublicProfileVisit] is set to true it will send push notification
  /// when showPublicProfileScreen is called
  /// this will send a push notification to the visited profile
  /// and indicating that the current user visited that profile
  ///
  ///
  bool enableMessagingOnPublicProfileVisit = false;

  /// [onLike] is called when a post is liked or unliked by the login user.
  void Function(User user, bool isLiked)? onLike;

  // Enable/Disable push notification when profile was liked
  bool enableNotificationOnLike = false;

  Function(UserModel)? onCreate;
  Function(UserModel)? onUpdate;

  UserService._() {
    dog('--> UserService._()');
  }

  init({
    bool enableNoOfProfileView = false,
    bool enableMessagingOnPublicProfileVisit = false,
    bool enableNotificationOnLike = false,
    Function(User user)? onSignout,
    void Function(User user, bool isLiked)? onLike,
    UserCustomize? customize,
    Function(UserModel user)? onCreate,
    Function(UserModel user)? onUpdate,
  }) {
    dog('--> UserService.init()');
    initUser();
    listenUser();

    if (customize != null) {
      this.customize = customize;
    }

    this.enableNoOfProfileView = enableNoOfProfileView;
    this.enableMessagingOnPublicProfileVisit =
        enableMessagingOnPublicProfileVisit;

    this.onLike = onLike;
    this.enableNotificationOnLike = enableNotificationOnLike;

    this.onCreate = onCreate;
    this.onUpdate = onUpdate;
  }

  /// 사용자 정보 초기화
  ///
  /// 회원 가입을 하지 않았거나, 최초 로그인인 경우, 문서가 존재하지 않을 수 있는데, 그와 같은 경우 새로운 문서를 생성한다.
  /// createdAt 이 없는 경우, createdAt  를 추가한다.
  /// order 가 없는 경우, order 를 추가한다.
  ///
  /// 이처럼, 회원 정보에 빠져 있는 내용을 이곳에서 추가 할 수 있다.
  initUser() {
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        return;
      }

      /// 사용자 문서 읽기
      UserModel? user = await UserModel.get(firebaseUser.uid);

      // ignore: prefer_conditional_assignment
      if (user == null) {
        user = await UserModel.create(
          uid: firebaseUser.uid,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
      }

      /// createdAt 이 없으면, 최초 로그인이다. 그래서 createdAt 을 지정해서
      /// 회원 가입으로 간주한다.
      if (user.createdAt == 0) {
        dog('--> User login for the first time. --> update createdAt');
        user.update(
          createdAt: ServerValue.timestamp,
        );
      }
    });
  }

  /// 주의, 이 함수의 callback 안에서, 회원 정보를 업데이트 해서는 안된다. 그러면 무한 재귀호출에 빠질 수 있다.
  listenUser() {
    dog('--> UserService.listenUser() for login user: $myUid');
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      dog('--> UserService.listenUser() FirebaseAuth.instance.authStateChanges()');
      if (user == null) {
        this.user = null;
        return;
      }
      userNodeSubscription?.cancel();
      userNodeSubscription =
          userRef.child(user.uid).onValue.listen((event) async {
        dog('--> UserService.listenUser() userRef.child(user.uid).onValue.listen()');
        if (event.snapshot.exists == false || event.snapshot.value == null) {
          return;
        }

        /// 사용자 문서 존재하지 않는 경우, 여기서 생성하면 안된다.
        /// 실제로, 사용자 문서가 존재하는데도 불구하고, 각종 읽기 실패, 인터넷 순단 등의 이유로 문서가 존재하지 않는 것으로
        /// 인식되어, 다시 문서를 생성하는 경우가 있다. 그리고 무한 루프를 돌 수도 있다.
        ///
        /// 위의, initUser() 에서, 사용자 로그인이 바뀌면 문서가 존재하는지 확인하고, 존재하지 않으면 사용자 문서를 생성
        /// 한다.

        /// 문서 파싱
        this.user = UserModel.fromSnapshot(event.snapshot);

        ///
        myDataChanges.add(this.user);
      });
    });
  }

  /// Open the user's public profile dialog
  ///
  /// It shows the public profile dialog for the user. You can customize by
  /// setting [UserCustomize] to [UserService.instance.customize].
  ///
  /// It does manythings like:
  /// - send notification when user visit other user profile
  /// - log when user visit other user profile
  /// - save profile view history
  /// - show public profile dialog
  ///
  /// You can customize by setting [UserCustomize] to [UserService.instance.customize].
  ///
  /// Send notification even if enableMessagingOnPublicProfileVisit is set to false
  /// set `notify` to `false` to prevent sending push notification
  /// used `notify` to `false` like admin visit the user profile
  Future showPublicProfile({
    required BuildContext context,
    required String uid,
  }) {
    /// Dynamic link is especially for users who are not install and not signed users.
    if (loggedIn && myUid != uid && enableNoOfProfileView) {
      /// TODO - 누가 나의 프로필을 보았는지, 기록을 남긴다. UID 를 추가해서, 숫자만 표시 할 수 있도록 한다.
    }

    /// TODO - 누가 나의 프로필을 보았는지, 기록을 남긴다. 한 사용자가 다른 사용자의 프로필을 중복으로 볼 때, 모든 기록을 남긴다.
    /// 날짜, 시간, 누가, 등...

    /// 누가 나의 프로필을 볼 때, 푸시 알림 보내기
    /// send notification by default when user visit other user profile
    /// disable notification when `disableNotifyOnProfileVisited` is set on user setting
    () async {
      bool? re =
          await getSetting<bool?>(uid, path: Code.profileViewNotification);
      if (re != true) return;

      if (loggedIn && myUid != uid) {
        // TODO send message if somebody visit my profile
        // MessagingService.instance.send(
        //   title: "Your profile was visited.",
        //   body: "${currentUser?.displayName} visit your profile",
        //   senderUid: myUid!,
        //   receiverUid: uid,
        //   action: 'profile',
        // );
      }
    }();

    return showGeneralDialog(
      context: context,
      pageBuilder: ($, _, __) =>
          customize.publicProfile?.call(uid) ??
          DefaultPublicProfileScreen(uid: uid),
    );
  }

  /// 사용자 설정 값을 리턴한다.
  ///
  /// [uid] 사용자 UID. 이 사용자의 설정을 리턴한다.
  ///
  /// [path] 를 입력하면, 해당 키의 값을 리턴한다. [path] 가 지정되지 않으면, 사용자의 전체 설정을 리턴한다.
  ///
  /// 예) 아래와 같이 하면, `user_settings/myUid/abc` 키의 값을 리턴한다.
  /// ```dart
  /// UserService.instance.getSetting(myUid, key: 'abc');
  /// ```
  getSetting<T>(String uid, {String? path}) async {
    final nodePath = otherSettingsRef(uid, path: path);
    dog('--> UserService.getSetting() nodePath: ${nodePath.path.toString()}');
    final snapshot = await nodePath.get();
    if (!snapshot.exists) {
      return null;
    }
    return snapshot.value as T;
  }

  login() async {
    await myRef.update({
      'lastLogin': ServerValue.timestamp,
    });
  }

  /// 로그인한 사용자의 프로필 수정 페이지를 보여준다.
  Future showProfile(BuildContext context) {
    return showGeneralDialog(
      context: context,
      pageBuilder: ($, $$, $$$) => const DefaultProfileScreen(),
    );
  }
}
