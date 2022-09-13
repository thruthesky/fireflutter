import 'package:cloud_firestore/cloud_firestore.dart';

/// UserSettingsModel
///
///
class UserSettingsModel {
  UserSettingsModel();

  Map<String, dynamic> topics = {};
  Map<String, dynamic> data = {};

  UserSettingsModel.fromSnapshot(DocumentSnapshot snapshot) {
    setProperties(snapshot.data());
  }

  UserSettingsModel.fromData(dynamic data) {
    setProperties(data);
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel.fromData({});
  }

  setProperties(dynamic data) {
    topics = Map<String, dynamic>.from(data['topic'] ?? {});
    data = Map<String, dynamic>.from(data);
  }

  // topicsFolder(String type) {
  //   return topics[type];
  // }

  // getTopicsFolderValue(String type, String topic) {
  //   return topics[type]?[topic];
  // }

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
  // Future<Json> read() async {
  //   final snapshot = await userSettingsDoc.get();
  //   if (snapshot.exists) {
  //     return Map<String, dynamic>.from(snapshot.value as dynamic);
  //   } else {
  //     return {} as Json;
  //   }
  // }

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
  Future<dynamic> updateSubscription(
      String topic, String type, bool isSubscribed) async {
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

  static Future<dynamic> enableAllNotification(
      {String? group, String? type}) async {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('enableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  static Future<dynamic> disableAllNotification(
      {String? group, String? type}) async {
    // TODO settings function on client only
    return Future.value();
    // return FunctionsApi.instance
    //     .request('disableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }
}
