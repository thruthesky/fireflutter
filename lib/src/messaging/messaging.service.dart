import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/messaging/user.profile.messaging.model.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    this.onNotificationPermissionNotDetermined =
        onNotificationPermissionNotDetermined;

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

    /// Save token to database when user logs in (or signs up)
    ///
    /// Subscribe the user auth changes for updating the token for the user.
    ///
    /// Run this subscription on the whole lifecycle. No need to subscribe
    /// since this will be called only one time.
    ///
    /// `/fcm_tokens/<docId>/{token: '...', uid: '...'}`
    /// Save(or update) token
    FirebaseAuth.instance
        .authStateChanges()
        .listen((user) => _updateToken(token));

    /// Token refreshed. update it.
    ///
    /// Run this subscription on the whole lifecycle. (No unsubscription)
    ///
    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => _updateToken(token));

    /// Get token from device and save it into Firestore
    ///
    /// Get the token each time the application loads and save it to database.

    try {
      token = await FirebaseMessaging.instance.getToken() ?? '';
    } on FirebaseException catch (e) {
      dog('Error while getting token: code: ${e.code}, message: ${e.message}, e: $e');
      rethrow;
    }
    await _updateToken(token);
  }

  /// Save tokens at `/user_fcm_tokens/<uid>/token/platform`
  _updateToken(String? token) async {
    if (FirebaseAuth.instance.currentUser == null) {
      dog("MessagingService::_updateToken() - Can't update token. User is not logged in.");
      return;
    }
    if (token == null) {
      // dog("MessagingService::_updateToken() - Can't update token. Token is null.");
      return;
    }
    try {
      dog('MessagingService::_updateToken() - Updating the device token: "$token" for myUid: $myUid');
      final data = {
        'uid': myUid,
        'platform': platformName(),
      };
      await set('${Messaging.userFcmTokens}/$token', data);
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
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
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
  /// [extra] is the data you pass to get the notification message type by "default" or if you are not passisng
  /// any extra data the norification is profile or user message type, by passing "roomId", and "messageId", the message type
  /// is "chat", and by pasing "id" which is postId and "category" the message type is post
  /// [id] is can be use to determined the landing page when notification is clicked
  /// heirarchy action >> topic >> tokens >> uids
  /// if action is not null, topic, tokens, uids will be ignored
  /// if action is null and topic is not null, then tokens and uids will be ignored
  /// if action and topic is null, and tokens is not null then uids will be ignored
  /// if action, topic, and tokens are null, then uids will be used
  ///
  /// [receiverUid] the receiver's uid. It can be null if the tokens are from multiple users.
  /// [numberOfChunks] the number of chunks is the number of token inside a chuncks the maximum number of chunks that th
  /// firebase cloud messging to send all at once is 1000.
  ///
  ///
  Future<Map<String, String>> send({
    required List<String> tokens,
    required String title,
    required String body,
    required String senderUid,
    String? badge,
    String? channelId,
    String? sound,
    String? action,
    Map<String, dynamic>? extra,
    int numberOfChunks = 255,
    bool removeInvalidTokens = true,
    String? image,
  }) async {
    /// remove empty tokens
    tokens = tokens.where((element) => element.isNotEmpty).toList();

    /// Chunk. check and separate the token by 255 per chunk
    List<List<String>> tokenChunck = [];
    for (int i = 0; i < tokens.length; i += numberOfChunks) {
      int end = (i + numberOfChunks < tokens.length)
          ? i + numberOfChunks
          : tokens.length;
      tokenChunck.add(tokens.sublist(i, end));
    }
    Map<String, String> responses = {};

    /// Send. send the token per group of chunk
    for (List<String> chunck in tokenChunck) {
      final data = {
        "title": title,
        "body": body,
        "data": {
          "senderUid": senderUid,
          "uid": senderUid,
          if (extra != null &&
              extra['id'] != null &&
              extra['category'] != null) ...{
            "id": extra['id'],
            "category": extra['category'],
          },
          if (extra != null &&
              extra['messageId'] != null &&
              extra['roomId'] != null) ...{
            "roomId": extra['roomId'],
            "messageId": extra['messageId'],
          }
        },
        "tokens": chunck,
        if (image != null) 'image': image
      };

      dog('tokens in this chunk ->>  ${chunck.length}, data: $data');

      final dio = Dio();
      try {
        final response = await dio.post(sendUrl!, data: data);

        final res = Map<String, String>.from(response.data);
        if (res['error'] != null) {
          dog('Error on calling firebase function: ${res['error']}');
        } else {
          responses.addAll(res);
        }
      } catch (e) {
        dog('Error on calling firebase function: $e');

        ///
      }
    }

    /// Note, don't remove the tokens from client.
    /// Something happened that, even if the token looks fine, it's producing
    /// invalid key error and token wsa removed from here.
    dog('no of bad tokens: ${responses.length}');
    for (final key in responses.keys) {
      dog('invalid key: $key - ${responses[key]}');
      // set("${Messaging.userFcmTokens}/$key", null);
    }

    return responses;
  }

  Future<Map<String, String>> sendAll({
    required String title,
    required String body,
    String? image,
    Map<String, dynamic>? extra,
  }) async {
    // 1. get all tokens
    final folders = await get<Map>(Messaging.userFcmTokens);
    if (folders == null) return {};

    // get all tokens from `/user-fcm-tokens`.
    final List<String> tokens = List<String>.from(folders.keys);

    // 2. send messages to all tokens
    final responses = await send(
        tokens: tokens,
        title: title,
        body: body,
        senderUid: myUid!,
        image: image,
        extra: extra);

    dog('sendAll() responses: $responses');

    return responses;
  }

  /// Send message to one user or multiple users
  /// [uid] sending a notification to a single uid
  /// [uids] sending a notification to multiple uids
  /// [extra] sending a extra data to determine what type of message your passing
  Future<Map<String, String>?> sendTo({
    String? uid,
    List<String>? uids,
    required String title,
    required String body,
    String? image,
    Map<String, dynamic>? extra,
  }) async {
    if (uid == null && uids == null) return null;

    uids ??= [uid!];

    if (uids.isEmpty) {
      dog('MessagingService Error --> uids must not not be empty');
    }

    // if (uid!.isNotEmpty) {
    //   final snapshot = await Ref.userTokens(uid).get();

    //   (snapshot.value as Map<String?, Object?>).forEach((k, p) {
    //     dog('key-> $k');
    //     tokens.add(k!);
    //   });
    //   dog('snapshot uid --> ${snapshot.value.runtimeType}');
    // }
    // 1. get all tokens
    List<String> tokens = [];
    for (uid in uids) {
      dog('lenght -> ${uids.length}');
      final snapshot = await Messaging.userTokens(uid).get();
      if (snapshot.value == null) continue;
      if (snapshot.exists == false) continue;

      // get all tokens from `/user-fcm-tokens`
      tokens.addAll(List<String>.from((snapshot.value! as Map).keys));
    }

    dog('tokens: $tokens');

    // 2. send messages to all tokens
    final responses = await send(
      tokens: tokens,
      title: title,
      body: body,
      image: image,
      senderUid: myUid!,
      extra: extra,
    );
    dog('sendTo() responses: $responses');
    return responses;
  }

  /// Parse message data from [RemoteMessage.data]
  ///
  /// Example:
  /// ```dart
  /// final data = MessagingService.instance.parseData(message.data);
  /// ```
  ///
  dynamic parseData(Map<String, dynamic> data) => switch (data) {
        {Field.postId: String _, Field.category: String _} =>
          CommentMessaging.fromMap(data),
        {Field.category: String _} => PostMessaging.fromMap(data),
        {Field.roomId: String _} => ChatMessaging.fromMap(data),
        {Field.senderUid: String _} => UserMessaging.fromMap(data),
        {Field.uid: String _} => UserProfileMessaging.fromMap(data),
        _ => null,
      };
}
