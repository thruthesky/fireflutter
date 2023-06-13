import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class ChatRoomModel {
  final String otherUserUid;
  final int noOfNewMessages;
  final int updatedAt;
  final ChatMessageModel lastMessage;

  ChatRoomModel({
    required this.otherUserUid,
    required this.noOfNewMessages,
    required this.updatedAt,
    required this.lastMessage,
  });

  factory ChatRoomModel.fromSnapshot(DataSnapshot snapshot) {
    log('snapsho val ${snapshot.value}');
    Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as dynamic);
    return ChatRoomModel.fromJson(json, snapshot.key!);
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String key) {
    final message = Map<String, dynamic>.from(json['lastMessage']);
    return ChatRoomModel(
        otherUserUid: key,
        lastMessage: ChatMessageModel.fromJson(message),
        noOfNewMessages: json['noOfNewMessages'],
        updatedAt: json['updatedAt']);
  }

  @override
  String toString() {
    return 'ChatRoomModel{otherUserUid: $otherUserUid, noOfNewMessages: $noOfNewMessages, updatedAt: $updatedAt, lastMessage: $lastMessage}';
  }
}
