import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/defines.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fireflutter/fireflutter.dart';

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
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  // final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

  MessagingService() {
    // debugPrint('MessagingService::constructor');
  }

  late Function(RemoteMessage) onForegroundMessage;
  late Function(RemoteMessage) onMessageOpenedFromTerminated;
  late Function(RemoteMessage) onMessageOpenedFromBackground;
  late Function onNotificationPermissionDenied;
  late Function onNotificationPermissionNotDetermined;
  String? token;
  final BehaviorSubject<String?> tokenChange = BehaviorSubject.seeded(null);

  final String prefixCustomTopic = 'customTopic';

  List<CustomizeMessagingTopic>? customizeTopic;

  bool initialized = false;

  init({
    required Future<void> Function(RemoteMessage)? onBackgroundMessage,
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onMessageOpenedFromTerminated,
    required Function(RemoteMessage) onMessageOpenedFromBackground,
    required Function onNotificationPermissionDenied,
    required Function onNotificationPermissionNotDetermined,
    List<CustomizeMessagingTopic>? customizeTopic,
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

    this.customizeTopic = customizeTopic;

    _init();
    _initilizeToken();
  }

  _initilizeToken() async {
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
    dog('---> device token: $token');
    await _updateToken(token);

    /// subscribe to topic on every boot
    _subscribeToTopic();
  }

  /// subscribe to topic
  /// default `allUsers`
  /// platform specific `iosUsers` `androidUsers` `webUsers` `${platformName()}Users`
  _subscribeToTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('allUsers');
    await FirebaseMessaging.instance.subscribeToTopic('${platformName()}Users');
  }

  Future subscribeToCustomTopic(String topic) async {
    if (initialized == false) return;
    await FirebaseMessaging.instance.subscribeToTopic('$prefixCustomTopic$topic');
  }

  Future unsubscribeToCustomTopic(String topic) async {
    if (initialized == false) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('$prefixCustomTopic$topic');
    } catch (e) {
      /// error will be thrown if the topic is not subscribed.
      log('unsubscribeToCustomTopic error: ${e.toString()}');
    }
  }

  /// `/users/<uid>/fcm_tokens/<docId>` 에 저장을 한다.
  _updateToken(String? token) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    if (token == null) return;
    final ref = tokenDoc(token);
    // debugPrint('ref; ${ref.path}');
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
  Future<DocumentReference> queue({
    required String title,
    required String body,
    List<String>? uids,
    List<String>? tokens,
    String? type,
    String? topic,
    String? id,
    String? badge,
    String? channelId,
    String? sound,
    String? action,
    String? categoryId,
  }) {
    Json data = {
      'title': title,
      'body': body,
      'senderUid': myUid!,
      'createdAt': FieldValue.serverTimestamp(),
      if (uids != null && uids.isNotEmpty) 'uids': uids,
      if (tokens != null && tokens.isNotEmpty) 'tokens': tokens,
      if (type != null && type.isNotEmpty) 'type': type,
      if (topic != null && topic.isNotEmpty) 'topic': topic,
      if (id != null && id.isNotEmpty) 'id': id,
      if (badge != null && badge.isNotEmpty) 'badge': badge,
      if (channelId != null && channelId.isNotEmpty) 'channelId': channelId,
      if (sound != null && sound.isNotEmpty) 'sound': sound,
      if (action != null && action.isNotEmpty) 'action': action,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
    };

    // print('data; $data');

    return messageQueueCol.add(data);
  }
}
