import 'package:firebase_database/firebase_database.dart';

class RChatRoomModel {
  String? key;
  String? text;
  String? url;
  int? updatedAt;
  int? newMessage;

  RChatRoomModel({
    this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.newMessage,
  });

  factory RChatRoomModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    return RChatRoomModel.fromJson(json);
  }

  factory RChatRoomModel.fromJson(Map<dynamic, dynamic> json) {
    return RChatRoomModel(
      key: json['key'] as String?,
      text: json['text'] as String?,
      url: json['url'] as String?,
      updatedAt: json['updatedAt'] is int ? json['updatedAt'] : int.parse(json['updatedAt'] ?? '0'),
      newMessage: json['newMessage'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'text': text,
      'url': url,
      'updatedAt': updatedAt,
      'newMessage': newMessage,
    };
  }
}
