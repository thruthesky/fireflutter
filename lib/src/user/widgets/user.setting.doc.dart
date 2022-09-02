import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import '../../../../fireflutter.dart';

/// UserSettingDoc
///
///
class UserSettingDoc extends StatefulWidget {
  const UserSettingDoc({required this.builder, Key? key}) : super(key: key);
  final Widget Function(UserSettingsModel) builder;

  @override
  State<UserSettingDoc> createState() => _UserSettingDocState();
}

class _UserSettingDocState extends State<UserSettingDoc> {
  UserSettingsModel settings = UserSettingsModel.empty();
  StreamSubscription? userSettingSubscriptoion;

  /// User settings event
  ///
  /// This event may be posted multiple times on user sign-in.
  /// It might be called muliple time on the app life cycle whenever user sign-out and sign-in.
  ///
  BehaviorSubject<UserSettingsModel?> settingChange = BehaviorSubject.seeded(null);

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((_user) async {
      userSettingSubscriptoion?.cancel();
      settings = UserSettingsModel.empty();
      if (_user == null) {
        /// Nothing to do when user signed-out.
      } else {
        /// When user sign-in, even if the user is anonymous, load the user's setting.

        /// TODO listen for user settings document and when updated, re-render. so the builder will build child widget.

        //   // 그리고 settings doc 을 listen.
        //   userSettingSubscriptoion = User.userSettingsDoc.onValue.listen((event) async {
        //     // Default - empty setting (if user settings doc does not exists.)
        //     if (event.snapshot.exists) {
        //       settings = UserSettingsModel.fromJson(event.snapshot.value);

        //       if (settings.password == '') {
        //         /// Generate password. This will update user settings doc and will fire another event.
        //         // log("---> password is empty. generate now");
        //         // await settings.generatePassword();
        //         throw ERROR_USER_PASSWORD_IS_EMPTY;
        //       }

        //       /// Post event only after the password generated.
        //       settingChange.add(settings);
        //       // log('---> user settings: $uid, password: ${settings.password}');
        //       update([ControllerUpdateID.settings]);
        //     } else {
        //       // User document and user setting document are created by the cloud function on user's registration.
        //       // When a user sign-in as Anonymous or as a real user,
        //       // The runtime action point may come here. But it is not an error. The user doc and user settings doc are created a little bit late.
        //       //
        //       // * Note, when a user signed-in as an Anonymous, [settingChange] will be called.
        //       // * And when the anonymous user signs into a real account, [settingChange] will not be called if the anonymous user sign-in with new phone number.
        //       // * But If the anonymous user signs-in with an existing account, then user's UID changes, and [settingChange] event will be posted.
        //     }

        //     // settingsLoaded.add(settings);
        //   }, onError: (e) {
        //     // print('====> UserSettingsDoc listening error; $e');
        //     throw e;
        //   });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(settings);
  }
}
