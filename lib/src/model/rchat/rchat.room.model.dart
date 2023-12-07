import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class RChatRoomModel {
  final DatabaseReference ref;
  String key;
  String name;
  String? text;
  String? url;
  int? updatedAt;
  int? newMessage;
  bool? isGroupChat;
  bool? isExists;

  /// [id] It returns the chat room id.
  ///
  /// This is used to save the messages under `/chat-messages/{id}/[messages]`.
  get id => isGroupChat == true ? key : RChat.singleChatRoomId(key);

  /// [path] is the path of the chat room.
  String get path => isGroupChat == true ? '/chat-rooms/$key' : '/chat-rooms/${RChat.singleChatRoomId(key)}';
  // String get path => '/chat-rooms/$key';

  RChatRoomModel({
    required this.ref,
    required this.key,
    required this.name,
    this.text,
    this.url,
    this.updatedAt,
    this.newMessage,
    this.isGroupChat,
    this.isExists,
  });

  /// get chat room using key
  static Future<RChatRoomModel> fromRoomId(String roomId) async {
    final roomRef = RChat.roomDetailsRef(roomId: roomId);
    final snapshot = await roomRef.get();
    // if it does not exist, it will not make error
    return RChatRoomModel.fromSnapshot(snapshot, id: roomId);
  }

  /// [fromSnapshot] It creates a [RChatRoomModel] from a [DataSnapshot].
  ///
  /// Example
  /// ```
  ///   final event = await RChat.roomRef(uid: data.roomId).once(DatabaseEventType.value);
  ///   final room = RChatRoomModel.fromSnapshot(event.snapshot);
  /// ```
  factory RChatRoomModel.fromSnapshot(DataSnapshot snapshot, {String? id}) {
    final json = (snapshot.value ?? {}) as Map<dynamic, dynamic>;
    json['key'] = snapshot.key ?? id;
    json['ref'] = snapshot.ref;
    json['isExists'] = snapshot.exists;
    return RChatRoomModel.fromJson(json);
  }

  factory RChatRoomModel.fromJson(Map<dynamic, dynamic> json) {
    dog("json users: ${json['users']}");
    dog("full json: $json");
    return RChatRoomModel(
      ref: json['ref'],
      key: json['key'],
      text: json['text'] as String?,
      url: json['url'] as String?,
      name: (json['name'] ?? "") as String,
      updatedAt: json['updatedAt'] is int ? json['updatedAt'] : int.parse(json['updatedAt'] ?? '0'),
      newMessage: json['newMessage'] ?? 0,
      isGroupChat: json['isGroupChat'],
      isExists: json['isExists'],
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
