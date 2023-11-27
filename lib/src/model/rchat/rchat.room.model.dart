import 'package:firebase_database/firebase_database.dart';

class RChatRoomModel {
  final DatabaseReference ref;
  String key;
  String? text;
  String? url;
  int? updatedAt;
  int? newMessage;

  RChatRoomModel({
    required this.ref,
    required this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.newMessage,
  });

  factory RChatRoomModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    json['ref'] = snapshot.ref;
    return RChatRoomModel.fromJson(json);
  }

  factory RChatRoomModel.fromJson(Map<dynamic, dynamic> json) {
    return RChatRoomModel(
      ref: json['ref'],
      key: json['key'],
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
