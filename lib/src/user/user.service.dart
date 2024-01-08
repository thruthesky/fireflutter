import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

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

  BehaviorSubject<UserModel?> myDataChanges = BehaviorSubject<UserModel?>.seeded(null);

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
  }) {
    dog('--> UserService.init()');
    listenUser();

    if (customize != null) {
      this.customize = customize;
    }

    this.enableNoOfProfileView = enableNoOfProfileView;
    this.enableMessagingOnPublicProfileVisit = enableMessagingOnPublicProfileVisit;

    this.onLike = onLike;
    this.enableNotificationOnLike = enableNotificationOnLike;
  }

  listenUser() {
    dog('--> UserService.listenUser() for login user: $myUid');
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      dog('--> UserService.listenUser() FirebaseAuth.instance.authStateChanges()');
      if (user == null) {
        this.user = null;
        return;
      }
      userNodeSubscription?.cancel();
      userNodeSubscription = userRef.child(user.uid).onValue.listen((event) async {
        dog('--> UserService.listenUser() userRef.child(user.uid).onValue.listen()');
        // final json = Map<String, dynamic>.from(event.snapshot.value);
        // this.user = UserModel.fromJson(json);

        /// 사용자 문서 존재하지 않는 경우, 생성
        ///
        /// 어떤 이유로 인해서 사용자 문서가 존재하지 않을 수 있다. 예를 들면, 테스트를 하는 경우 등에서 발생할 수 있는데,
        /// 이와 같은 경우, 그냥 문서를 생성해 준다.
        ///
        /// If the user document does not exsit. Then create it.
        if (event.snapshot.exists == false) {
          dog('--> 어떤 이유(테스트 등)로 인해 사용자 문서 존재하지 않음, 생성함.');
          await userRef.child(user.uid).set({
            'email': user.email,
            'displayName': user.displayName,
            'photoUrl': user.photoURL,
            'createdAt': ServerValue.timestamp,
          });
          return;
        }

        /// 문서 파싱
        this.user = UserModel.fromSnapshot(event.snapshot);

        ///
        myDataChanges.add(this.user);

        /// 문서를 읽지 못했거나, createdAt 이 없으면, 최초 로그인이다. 그래서 createdAt 을 지정해서
        /// 회원 가입으로 간주한다.
        if (this.user?.createdAt == null) {
          dog('--> User login for the first time. --> update createdAt');
          this.user?.ref.update({
            'createdAt': ServerValue.timestamp,
          });
        }
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
      bool? re = await getSetting<bool?>(uid, path: Code.profileViewNotification);
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

    /// 커스텀 디자인을 사용하면, 커스텀 디자인을 보여준다.
    if (customize.showPublicProfile != null) {
      return customize.showPublicProfile!(context, uid);
    }

    return showGeneralDialog(
      context: context,
      pageBuilder: ($, _, __) => DefaultPublicProfileScreen(uid: uid),
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
