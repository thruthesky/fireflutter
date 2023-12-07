import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class RChatRoomModel {
  final DatabaseReference ref;
  String key;
  String? text;
  String? url;
  int? updatedAt;
  int? newMessage;
  bool? isGroupChat;

  /// [id] It returns the chat room id.
  ///
  /// This is used to save the messages under `/chat-messages/{id}/[messages]`.
  get id => isGroupChat == true ? key : RChat.singleChatRoomId(key);

  /// [path] is the path of the chat room.
  String get path => isGroupChat == true ? '/chat-rooms/$key' : '/chat-rooms/${RChat.singleChatRoomId(key)}';

  RChatRoomModel({
    required this.ref,
    required this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.newMessage,
    this.isGroupChat,
  });

  /// [fromSnapshot] It creates a [RChatRoomModel] from a [DataSnapshot].
  ///
  /// Example
  /// ```
  ///   final event = await RChat.roomRef(uid: data.roomId).once(DatabaseEventType.value);
  ///   final room = RChatRoomModel.fromSnapshot(event.snapshot);
  /// ```
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
      isGroupChat: json['isGroupChat'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'text': text,
      'url': url,
      'updatedAt': updatedAt,
      'newMessage': newMessage,
      'isGroupChat': isGroupChat,
    };
  }
}
