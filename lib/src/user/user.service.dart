import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class UserService {
  static late final UserService? _instance;
  static UserService get instance => _instance ??= UserService._();

  UserModel? user;
  final rtdb = FirebaseDatabase.instance.ref();
  DatabaseReference get userRef => rtdb.child('users');

  StreamSubscription? userNodeSubscription;

  UserCustomize customize = UserCustomize();

  /// User create event. It fires when a user document is created.
  Function(User user)? onCreate;

  /// If any of the user document field updates, then this callback will be called.
  /// For instance, when a user creates a post or a comment, the no of posts or
  /// comments are updated in user document. Hence [onUpdate] will be called.
  /// Warning, don't call UserService.instance.update() inside this callback. It
  /// will cause an infinite loop. You may use the firestore SDK to update the
  /// user document.
  ///
  /// [user] is the user model that has new data (after update).
  ///
  /// [data] it has the fields and values in Map that are updated. You can use
  /// it to know which fields are updated.
  /// updated.
  Function(User user, Map<String, dynamic> data)? onUpdate;
  Function(User user)? onDelete;

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
    print('--> UserService._()');
  }

  init({
    bool enableNoOfProfileView = false,
    bool enableMessagingOnPublicProfileVisit = false,
    bool enableNotificationOnLike = false,
    Function(User user)? onCreate,
    Function(User user, Map<String, dynamic> data)? onUpdate,
    Function(User user)? onDelete,
    Function(User user)? onSignout,
    void Function(User user, bool isLiked)? onLike,
    UserCustomize? customize,
  }) {
    print('--> UserService.init()');
    listenUser();

    if (customize != null) {
      this.customize = customize;
    }

    this.enableNoOfProfileView = enableNoOfProfileView;
    this.enableMessagingOnPublicProfileVisit = enableMessagingOnPublicProfileVisit;
    this.onCreate = onCreate;

    /// [onUpdate] will be triggered every time user is being updated.
    /// See user.dart and check the [update] method.
    this.onUpdate = onUpdate;
    this.onDelete = onDelete;
    this.onSignout = onSignout;

    this.onLike = onLike;
    this.enableNotificationOnLike = enableNotificationOnLike;
  }

  listenUser() {
    print('--> UserService.listenUser()');
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      print('--> UserService.listenUser() FirebaseAuth.instance.authStateChanges()');
      if (user == null) {
        this.user = null;
        return;
      }
      userNodeSubscription?.cancel();
      userNodeSubscription = userRef.child(user.uid).onValue.listen((event) {
        print('--> UserService.listenUser() userRef.child(user.uid).onValue.listen()');
        final json = event.snapshot.value as Map<String, dynamic>;
        this.user = UserModel.fromJson(json);
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
  Future showPublicProfileDialog({
    required BuildContext context,
    required String uid,
  }) {
    /// Dynamic link is especially for users who are not install and not signed users.
    if (loggedIn && myUid != uid && enableNoOfProfileView) {
      /// TODO - 누가 나의 프로필을 보았는지, 기록을 남긴다. UID 를 추가해서, 숫자만 표시 할 수 있도록 한다.
    }

    /// TODO - 누가 나의 프로필을 보았는지, 기록을 남긴다. 한 사용자가 다른 사용자의 프로필을 중복으로 볼 때, 모든 기록을 남긴다.
    /// 날짜, 시간, 누가, 등...

    if (customize.showPublicProfileDialog != null) {
      return customize.showPublicProfileDialog!(context, uid);
    }

    /// 누가 나의 프로필을 볼 때, 푸시 알림 보내기
    /// send notification by default when user visit other user profile
    /// disable notification when `disableNotifyOnProfileVisited` is set on user setting
    () async {
      bool re = await getSetting(uid, path: Def.profileViewNotification);
      if (re != true) return;

      if (loggedIn && myUid != uid) {
        MessagingService.instance.send(
          title: "Your profile was visited.",
          body: "${currentUser?.displayName} visit your profile",
          senderUid: myUid!,
          receiverUid: uid,
          action: 'profile',
        );
      }
    }();

    return showGeneralDialog(
      context: context,
      pageBuilder: ($, _, __) => DefaultPublicProfileDialog(uid: uid),
    );
  }

  /// 사용자 설정 값을 리턴한다.
  ///
  /// [path] 를 입력하면, 해당 키의 값을 리턴한다.
  /// 예) 아래와 같이 하면, `user_settings/myUid/abc` 키의 값을 리턴한다.
  /// ```dart
  /// UserService.instance.getSetting(myUid, key: 'abc');
  /// ```
  getSetting(String uid, {String? path}) {
    return get('user_settings/$uid${path != null ? '/$path' : ''}');
  }
}
