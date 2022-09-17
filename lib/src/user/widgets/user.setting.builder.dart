import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// If the document does not exists, the settings passed to builder will be a null.
class MySettingsBuilder extends StatelessWidget {
  const MySettingsBuilder(
      {super.key, this.id = 'settings', required this.builder});

  final Widget Function(Map<String, dynamic>? settings) builder;
  final String id;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(UserService.instance.uid!)
            .collection('user_settings')
            .doc(id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }
          if (snapshot.hasError) {
            log("MySettingsBuiler($id) error: ${snapshot.error}");
            return Text(snapshot.error.toString());
          }

          Map<String, dynamic>? settings;
          if (snapshot.data != null && snapshot.data?.exists == true) {
            settings = snapshot.data?.data() as Map<String, dynamic>;
          }
          return builder(settings);
        });
  }
}

// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:rxdart/subjects.dart';
// import 'package:fireflutter/fireflutter.dart';

// /// MySettingsBuilder
// ///
// ///
// class MySettingsBuilder extends StatefulWidget {
//   const MySettingsBuilder({required this.builder, Key? key}) : super(key: key);
//   final Widget Function(UserSettingsModel) builder;

//   @override
//   State<MySettingsBuilder> createState() => _UserSettingDocState();
// }

// class _UserSettingDocState extends State<MySettingsBuilder> {
//   UserSettingsModel settings = UserSettingsModel.empty();
//   StreamSubscription? userSettingSubscription;

//   /// User settings event
//   ///
//   /// This event may be posted multiple times on user sign-in.
//   /// It might be called muliple time on the app life cycle whenever user sign-out and sign-in.
//   ///
//   BehaviorSubject<UserSettingsModel?> settingChange =
//       BehaviorSubject.seeded(null);

//   @override
//   void initState() {
//     super.initState();
//     FirebaseAuth.instance.authStateChanges().listen((_user) async {
//       userSettingSubscription?.cancel();
//       settings = UserSettingsModel.empty();
//       if (_user == null) {
//         /// Nothing to do when user signed-out.
//       } else {
//         /// When user sign-in, even if the user is anonymous, load the user's setting.

//         /// TODO listen for user settings document and when updated, re-render. so the builder will build child widget.

//         //   // 그리고 settings doc 을 listen.
//         //   userSettingSubscription = User.userSettingsDoc.onValue.listen((event) async {
//         //     // Default - empty setting (if user settings doc does not exists.)
//         //     if (event.snapshot.exists) {
//         //       settings = UserSettingsModel.fromJson(event.snapshot.value);

//         //       if (settings.password == '') {
//         //         /// Generate password. This will update user settings doc and will fire another event.
//         //         // log("---> password is empty. generate now");
//         //         // await settings.generatePassword();
//         //         throw ERROR_USER_PASSWORD_IS_EMPTY;
//         //       }

//         //       /// Post event only after the password generated.
//         //       settingChange.add(settings);
//         //       // log('---> user settings: $uid, password: ${settings.password}');
//         //       update([ControllerUpdateID.settings]);
//         //     } else {
//         //       // User document and user setting document are created by the cloud function on user's registration.
//         //       // When a user sign-in as Anonymous or as a real user,
//         //       // The runtime action point may come here. But it is not an error. The user doc and user settings doc are created a little bit late.
//         //       //
//         //       // * Note, when a user signed-in as an Anonymous, [settingChange] will be called.
//         //       // * And when the anonymous user signs into a real account, [settingChange] will not be called if the anonymous user sign-in with new phone number.
//         //       // * But If the anonymous user signs-in with an existing account, then user's UID changes, and [settingChange] event will be posted.
//         //     }

//         //     // settingsLoaded.add(settings);
//         //   }, onError: (e) {
//         //     // print('====> MySettingsBuilder listening error; $e');
//         //     throw e;
//         //   });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.builder(settings);
//   }
// }
