import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

/// TODO convert it as a model
typedef MessageData = ({
  dynamic badge,
  String? postId,
  String? roomId,
  String? uid,
  String senderUid,
});

class CustomizeMessagingTopic {
  final String topic;
  final String title;

  CustomizeMessagingTopic({
    required this.topic,
    required this.title,
  });
}

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
/// [onMessageOpenedFromTerminated] will be called when the user tapped on the push notification
/// on system tray while the app was closed(terminated).
///
///
///
class MessagingService {
  static MessagingService? _instance;
  static MessagingService get instance => _instance ??= MessagingService._();

  // final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

  MessagingService._() {
    // debugPrint('MessagingService::constructor');
  }

  late Function(RemoteMessage) onForegroundMessage;
  late Function(RemoteMessage) onMessageOpenedFromTerminated;
  late Function(RemoteMessage) onMessageOpenedFromBackground;
  late Function onNotificationPermissionDenied;
  late Function onNotificationPermissionNotDetermined;

  String? sendUrl;
  String? token;
  final BehaviorSubject<String?> tokenChange = BehaviorSubject.seeded(null);

  List<CustomizeMessagingTopic>? customizeTopic;

  bool initialized = false;

  init({
    required Future<void> Function(RemoteMessage)? onBackgroundMessage,
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onMessageOpenedFromTerminated,
    required Function(RemoteMessage) onMessageOpenedFromBackground,
    required Function onNotificationPermissionDenied,
    required Function onNotificationPermissionNotDetermined,
    String? sendUrl,
  }) {
    initialized = true;
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTerminated = onMessageOpenedFromTerminated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;

    this.sendUrl = sendUrl;

    _initializeListeners();
    _initializeToken();
  }

  _initializeToken() async {
    /// Get permission
    ///
    /// Permission request for iOS only. For Android, the permission is granted by default.
    ///
    if (kIsWeb || Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
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

    /// Token update on user change(login/logout)
    ///
    /// Run this subscription on the whole lifecycle. (No unsubscription)
    ///
    /// `/fcm_tokens/<docId>/{token: '...', uid: '...'}`
    /// Save(or update) token
    FirebaseAuth.instance.authStateChanges().listen((user) => _updateToken(token));

    /// Token changed. update it.
    ///
    /// Run this subscription on the whole lifecycle. (No unsubscription)
    tokenChange.listen(_updateToken);

    /// Token refreshed. update it.
    ///
    /// Run this subscription on the whole lifecycle. (No unsubscription)
    ///
    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) => tokenChange.add(token));

    /// Get token from device and save it into Firestore
    ///
    /// Get the token each time the application loads and save it to database.
    token = await FirebaseMessaging.instance.getToken() ?? '';
    await _updateToken(token);
  }

  /// Save tokens at `/user_fcm_tokens/<uid>/token/platform`
  _updateToken(String? token) async {
    if (FirebaseAuth.instance.currentUser == null) {
      dog("Can't update token. User is not logged in.");
      return;
    }
    dog('Updating the device token: $token');
    if (token == null) return;
    try {
      await set('user-fcm-tokens/$myUid/$token', platformName());
    } catch (e) {
      dog('Error while updating token: $e');
      rethrow;
    }
  }

  /// Initialize Messaging
  _initializeListeners() async {
    // Handler, when app is on Foreground.
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Check if app is opened from CLOSED(TERMINATED) state and get message data.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedFromTerminated(initialMessage);
    }

    // Check if the app is opened(running) from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpenedFromBackground(message);
    });
  }

  /// [uids] 는 배열로 입력되어야 하고, 여기서 콤마로 분리된 문자열로 만들어 서버로 보낸다. 즉, 서버에서는 문자열이어야 한다.
  ///
  /// [target] is the target of devices you want to send message to. If it's "all", then it will send messages to all users.
  /// [type] is the kind of push notification `post` `chat`
  /// [id] is can be use to determined the landing page when notification is clicked
  /// heirarchy action >> topic >> tokens >> uids
  /// if action is not null, topic, tokens, uids will be ignored
  /// if action is null and topic is not null, then tokens and uids will be ignored
  /// if action and topic is null, and tokens is not null then uids will be ignored
  /// if action, topic, and tokens are null, then uids will be used
  ///
  ///
  /// TODO: what if there is too much tokens? chunk it by 255 tokens and send them all at once.
  ///
  /// TODO: remove invalid tokens from database.
  ///
  Future<Map<String, String>> send({
    required List<String> tokens,
    required String title,
    required String body,
    required String senderUid,
    required String receiverUid,
    String? badge,
    String? channelId,
    String? sound,
    String? action,
    Map<String, dynamic>? extra,
    int numberOfChunks = 255,
  }) async {
    /// remove empty tokens
    tokens = tokens.where((element) => element.isNotEmpty).toList();

    /// check and separate the token by 255 per chunk
    List<List<String>> tokenChunck = [];
    for (int i = 0; i < tokens.length; i += numberOfChunks) {
      int end = (i + numberOfChunks < tokens.length) ? i + numberOfChunks : tokens.length;
      tokenChunck.add(tokens.sublist(i, end));
    }

    Map<String, String> responses = {};

    /// send the token per group of chunk
    for (List<String> chunck in tokenChunck) {
      Map<String, dynamic> data = {
        "title": title,
        "body": body,
        "data": {"senderUid": senderUid, "receiverUid": receiverUid},
        "tokens": chunck
      };

      dog('tokens in this chunk ->>  ${chunck.length}');

      final dio = Dio();
      try {
        final response = await dio.post(sendUrl!, queryParameters: data);

        final res = Map<String, String>.from(response.data);
        responses.addAll(res);
      } catch (e) {
        dog('error: $e');

        ///
      }
    }

    return responses;
  }

  /// Parse message data from [RemoteMessage.data]
  ///
  /// {badge: , id: so7HI41U2QfQRu86B7EF, roomId: , type: post, senderUid: 2F49sxIA3JbQPp38HHUTPR2XZ062, action: }
  ///
  MessageData parseMessageData(Map<String, dynamic> data) {
    return (
      badge: data['badge'],
      postId: data['postId'],
      roomId: data['roomId'] ?? '',
      uid: data['uid'] ?? '',
      senderUid: data['senderUid'],
    );
  }
}
