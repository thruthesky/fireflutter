import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatMessageModel {
  String? key;
  String? uid;
  String? text;
  String? url;
  int? order;
  int? createdAt;

  bool get mine => uid == FirebaseAuth.instance.currentUser!.uid;
  bool get other => !mine;

  ChatMessageModel({
    this.key,
    this.uid,
    this.text,
    this.url,
    this.order,
    this.createdAt,
  });

  factory ChatMessageModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    return ChatMessageModel.fromJson(json);
  }

  factory ChatMessageModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessageModel(
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
