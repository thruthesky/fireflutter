import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserSettingsModel
///
///
class UserSettingsModel {
  UserSettingsModel({
    required this.topics,
    required this.data,
    required this.password,
  });

  DatabaseReference get userSettingsDoc =>
      FirebaseDatabase.instance.ref('user-settings').child(User.instance.uid!);

  Map<String, dynamic> topics;
  Map<String, dynamic> data;
  String password;
  factory UserSettingsModel.fromJson(dynamic data) {
    return UserSettingsModel(
      topics: Map<String, dynamic>.from(data['topic'] ?? {}),
      data: Map<String, dynamic>.from(data),
      password: data['password'] ?? '',
    );
  }

  topicsFolder(String type) {
    return topics[type];
  }

  getTopicsFolderValue(String type, String topic) {
    return topics[type]?[topic];
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel(topics: {}, data: {}, password: '');
  }

  /// Create user-setting document for the first time with time and password.
  ///
  /// This method is being invoked by `UserSettingService::initAuthChanges` and sets
  /// user's password for the first time.
  // Future<UserSettingsModel> create() async {
  //   await userSettingsDoc.set({
  //     'timestamp': ServerValue.timestamp,
  //     'password': getRandomString(),
  //   });
  //   return this.get();
  // }

  /// Generate new password for the user.
  ///
  /// Note, this should be called only if the user has no password, yet.
  ///
  // Future<void> deprecatedGeneratePassword() async {
  //   final pw = getRandomString();
  //   await userSettingsDoc.update({
  //     'password': pw,
  //   });
  //   password = pw;
  // }

  Future<UserSettingsModel> get() async {
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return UserSettingsModel.fromJson(snapshot.value);
    } else {
      return UserSettingsModel.empty();
    }
  }

  /// Update user setting
  ///
  /// ! For topic subscription, the app must use the cloud function.
  ///
  /// ```dart
  /// update({  'password': 'xxx' });
  ///
  Future<void> update(Json settings) async {
    ///
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return userSettingsDoc.update(settings);
    } else {
      return userSettingsDoc.set(settings);
    }
  }

  /// Returns the value of the key
  value(String key) {
    return data[key];
  }

  /// Returns the value of the key or null
  ///
  // static value(String key) {
  //   return data[key];
  // }

  /// Update user setting.
  // Future<void> update(Json data) async {
  //   return settings.update(data);
  // }

  /// Get user settings doc from realtime database
  Future<Json> read() async {
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as dynamic);
    } else {
      return {} as Json;
    }
  }

  /// Returns true if the user has subscribed the topic.
  /// If user subscribed the topic, that topic name will be saved into user meta in backend
  /// And when user profile is loaded, the subscriptions are saved into [subscriptions]
  bool hasSubscription(String topic, String type) {
    return data['topic']?[type]?[topic] ?? false;
  }

  bool hasDisabledSubscription(String topic, String type) {
    if (data['topic'] == null) return false;
    if (data['topic'][type] == null) return false;
    if (data['topic'][type][topic] == null) return false;
    if (data['topic'][type][topic] == false) return true;
    return false;
  }

  /// Updates the subscriptions (subscribe or unsubscribe) of the current user.
  Future<dynamic> updateSubscription(String topic, String type, bool isSubscribed) async {
    if (isSubscribed) {
      await subscribe(topic, type);
    } else {
      await unsubscribe(topic, type);
    }
  }

  /// Toggle the subscription (subscribe or unsubscribe) of the current user.
  toggleSubscription(String topic, String type) {
    return updateSubscription(
      topic,
      type,
      !hasSubscription(topic, type),
    );
  }

  Future<dynamic> subscribe(String topic, String type) {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('subscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<dynamic> unsubscribe(String topic, String type) {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('unsubscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<dynamic> topicOn(String topic, String type) {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('topicOn', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<dynamic> topicOff(String topic, String type) {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('topicOff', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<dynamic> toggleTopic(String topic, String type, bool toggle) async {
    if (toggle) {
      await topicOn(topic, type);
    } else {
      await topicOff(topic, type);
    }
  }

  /// Functions

  static Future<dynamic> enableAllNotification({String? group, String? type}) async {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('enableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  static Future<dynamic> disableAllNotification({String? group, String? type}) async {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('disableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }
}
