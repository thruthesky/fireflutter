import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fireflutter/fireflutter.dart';

/// MessagingService
///
/// Push notification will be appears on system tray(or on the top of the mobile device)
/// when the app is closed or in background state.
///
/// [onBackgroundMessage] is being invoked when the app is closed(terminated). (NOT running the app.)
///
/// [onForegroundMessage] will be called when the user(or device) receives a push notification
/// while the app is running and in foreground state.
///
/// [onMessageOpenedFromBackground] will be called when the user tapped on the push notification
/// on system tray while the app was running but in background state.
///
/// [onMessageOpenedFromTermiated] will be called when the user tapped on the push notification
/// on system tray while the app was closed(terminated).
///
///
///
class MessagingService with FireFlutterMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  // final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

  MessagingService() {
    // debugPrint('MessagingService::constructor');
  }

  late Function(RemoteMessage) onForegroundMessage;
  late Function(RemoteMessage) onMessageOpenedFromTermiated;
  late Function(RemoteMessage) onMessageOpenedFromBackground;
  late Function onNotificationPermissionDenied;
  late Function onNotificationPermissionNotDetermined;
  String? token;
  final BehaviorSubject<String?> tokenChange = BehaviorSubject.seeded(null);

  String defaultTopic = 'defaultTopic';
  bool doneDefaultTopic = false;

  // StreamSubscription? sub;

  init({
    required Future<void> Function(RemoteMessage)? onBackgroundMessage,
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onMessageOpenedFromTermiated,
    required Function(RemoteMessage) onMessageOpenedFromBackground,
    required Function onNotificationPermissionDenied,
    required Function onNotificationPermissionNotDetermined,
  }) {
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined =
        onNotificationPermissionNotDetermined;
    _init();
  }

  /// `/users/<uid>/fcm_tokens/<docId>` 에 저장을 한다.
  _updateToken(String? token) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (token == null) return;
    final ref = tokenDoc(token);
    print('ref; ${ref.path}');
    await ref.set(
      {
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'device_type': platformName(),
        'fcm_token': token,
      },
      SetOptions(merge: true),
    );
  }

  /// Initialize Messaging
  _init() async {
    /// 앱이 실행되는 동안 listen 하므로, cancel 하지 않음.
    /// `/fcm_tokens/<docId>/{token: '...', uid: '...'}`
    /// Save(or update) token
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) => _updateToken(token));

    ///
    tokenChange.listen((token) => _updateToken(token));

    /// Permission request for iOS only. For Android, the permission is granted by default.

    if (kIsWeb || Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      /// Check if permission had given.
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return onNotificationPermissionDenied();
      }
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        return onNotificationPermissionNotDetermined();
      }
    }

    // Get the token each time the application loads and save it to database.
    token = await FirebaseMessaging.instance.getToken() ?? '';
    log('---> device token: $token');
    // print(token);
    tokenChange.add(token);
    // debugPrint(token);

    // Handler, when app is on Foreground.
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Check if app is opened from CLOSED(TERMINATED) state and get message data.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedFromTermiated(initialMessage);
    }

    // Check if the app is opened(running) from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpenedFromBackground(message);
    });

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => tokenChange.add(token));
  }

  send({
    required String token,
    required String title,
    required String body,
  }) async {
    /// doc: https://firebase.google.com/docs/cloud-messaging/http-server-ref
    const apiUrl = "https://fcm.googleapis.com/fcm/send";
    final data = {
      "to": token,
      "notification": {
        "title": title,
        "body": body,
      },
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    Dio dio = getRetryDio();

    final res = await dio.post(
      apiUrl,
      data: data,
      options: Options(
        headers: {
          'content-type': 'application/json',
          'Authorization':
              'key=AAAAWy4G2hU:APA91bG8FpX2kNKMTRlTyiAEo3jDCg6UsiXlmVqCU-7syY0DGgpv_7VVJVpuQRoZqqzmBdUg_BWuluihF6nLwHt3yZpkfXvzzJidyp4_Ku-NgicQa0GT9Rilj_ks83HWSpAoVjaCFN7S',
        },
      ),
    );

    print(res.statusCode);
    print(res.data);
  }

//   /// https://firebase.google.com/docs/cloud-messaging/migrate-v1
//   /// Migrate from legacy HTTP to HTTP v1
//   send({
//     required String token,
//     required String title,
//     required String body,
//   }) async {
//     const apiUrl =
//         "https://fcm.googleapis.com/v1/projects/wonderful-korea/messages:send";
//     final data = {
//       "to": token,
//       "notification": {
//         "title": title,
//         "body": body,
//       },
//       "data": {
//         "click_action": "FLUTTER_NOTIFICATION_CLICK",
//       },
//     };

//     Dio dio = getRetryDio();

//     final res = await dio.post(
//       apiUrl,
//       data: data,
//       options: Options(
//         headers: {
//           'content-type': 'application/json',
//           'Authorization': "...",
//         },
//       ),
//     );

//     print(res.statusCode);
//     print(res.data);
//   }
}
