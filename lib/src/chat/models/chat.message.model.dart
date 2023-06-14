//import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
// import 'package:fireflowapp/etc/defines.dart';
//import 'package:intl/intl.dart';

class ChatMessageModel {
  final String senderUid;
  final DateTime createdAt;
  final String text;
  final int orderNo;
  final String photoUrl;
  final String protocol;

  ChatMessageModel({
    required this.senderUid,
    required this.createdAt,
    required this.text,
    required this.orderNo,
    required this.photoUrl,
    required this.protocol,
  });

  factory ChatMessageModel.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as dynamic);
    return ChatMessageModel.fromJson(json);
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      senderUid: json['senderUid'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      text: json['text'] ?? '',
      orderNo: json['orderNo'] ?? 0,
      photoUrl: json['photoUrl'] ?? '',
      protocol: json['protocol'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel{text: $text}';
  }
}

class ChatRoomData {
  final String? key;
  final Object noOfNewMessages;
  final ChatMessageModel lastMessage;
  final Object updatedAt;

  ChatRoomData({this.key, required this.noOfNewMessages, required this.lastMessage, required this.updatedAt});
}
