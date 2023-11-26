import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class RChatMessageModel {
  String? key;
  String? uid;
  String? text;
  String? url;
  int? order;
  int? createdAt;

  bool get mine => uid == myUid;

  RChatMessageModel({
    this.key,
    this.uid,
    this.text,
    this.url,
    this.order,
    this.createdAt,
  });

  factory RChatMessageModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    return RChatMessageModel.fromJson(json);
  }

  factory RChatMessageModel.fromJson(Map<dynamic, dynamic> json) {
    return RChatMessageModel(
      key: json['key'] as String?,
      uid: json['uid'] as String?,
      text: json['text'] as String?,
      url: json['url'] as String?,
      order: json['order'] as int?,
      createdAt: json['createdAt'] is int ? json['createdAt'] : int.parse(json['createdAt'] ?? '0'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'uid': uid,
      'text': text,
      'url': url,
      'createdAt': createdAt,
    };
  }
}
