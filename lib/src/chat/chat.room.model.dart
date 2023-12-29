import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireship/fireship.dart';

class ChatRoomModel {
  final DatabaseReference ref;
  String key;
  String? text;
  String? url;
  int? updatedAt;
  int? createdAt;
  int? newMessage;
  bool isGroupChat;
  bool isOpenGroupChat;
  String? name;
  String? photoUrl;
  String? description;
  String? master;
  Map<String, bool>? users;
  int? order;

  /// [id] It returns the chat room id.
  ///
  /// It is the node key of the chat room like the id in `/chat-rooms/{id}`.
  /// To get the message node id for both of 1:1 chat and group chat for saving message, use [messageRoomId]
  ///
  String get id => key;

  /// [path] is the path of the chat room.
  String get path => ref.path;

  bool get isSingleChat => !isGroupChat;

  ChatRoomModel({
    required this.ref,
    required this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.createdAt,
    this.newMessage,
    required this.isGroupChat,
    required this.isOpenGroupChat,
    this.name,
    this.photoUrl,
    this.description,
    this.master,
    this.users,
    this.order,
  });

  /// [fromSnapshot] It creates a [ChatRoomModel] from a [DataSnapshot].
  ///
  /// Example
  /// ```
  ///   final event = await RChat.roomRef(uid: data.roomId).once(DatabaseEventType.value);
  ///   final room = ChatRoomModel.fromSnapshot(event.snapshot);
  /// ```
  factory ChatRoomModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    json['ref'] = snapshot.ref;
    return ChatRoomModel.fromJson(json);
  }

  factory ChatRoomModel.fromJson(Map<dynamic, dynamic> json) {
    return ChatRoomModel(
      ref: json['ref'],
      key: json['key'],
      text: json['text'] as String?,
      url: json['url'] as String?,
      updatedAt: json['updatedAt'] is int
          ? json['updatedAt']
          : int.parse(json['updatedAt'] ?? '0'),
      createdAt: json['createdAt'] is int
          ? json['createdAt']
          : int.parse(json['createdAt'] ?? '0'),
      newMessage: json['newMessage'] ?? 0,

      /// See, rchat.md#database structure
      isGroupChat: isSingleChatRoom(json['key']) == false,
      isOpenGroupChat: json['isOpenGroupChat'] ?? false,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      master: json['master'] as String?,
      users:
          json['users'] == null ? null : Map<String, bool>.from(json['users']),
      order: json['order'] is int
          ? json['order']
          : int.parse(json['order'] ?? '0'),
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
      'isOpenGroupChat': isOpenGroupChat,
      'name': name,
      'photoUrl': photoUrl,
      'description': description,
      'master': master,
      'users': users,
      'order': order,
    };
  }

  /// toString
  @override
  String toString() {
    return 'ChatRoomModel(${toJson()})';
  }

  /// Returns a [ChatRoomModel] from a group id.
  ///
  /// Note that, single chat room ref is like /chat-rooms/uidA/uidB
  ///   while group chat room ref is like /chat-rooms/groupId.
  ///
  /// This is a factory. So, you can use it for creating a chat room model object programmatically.
  factory ChatRoomModel.fromRoomdId(String id) {
    return ChatRoomModel.fromJson({
      'key': id,
      'ref': ChatService.instance.roomsRef.child(id),
    });
  }

  // /// Returns a [ChatRoomModel] from a single chat room id.
  // factory ChatRoomModel.fromUid(String otherUserUid) {
  //   return ChatRoomModel.fromJson({
  //     'key': singleChatRoomId(otherUserUid),
  //     'ref': RChat.roomRef(singleChatRoomId(otherUserUid)),
  //     'isGroupChat': false,
  //     'isOpenGroupChat': false,
  //   });
  // }

  /// Return ChatRoomModel from a reference
  ///
  ///
  static Future<ChatRoomModel> fromReference(DatabaseReference ref) async {
    final event = await ref.once();
    if (event.snapshot.exists == false) {
      throw Exception(
          'ChatRoomModel.fromReference: ${ref.path} does not exist.');
    }
    return ChatRoomModel.fromSnapshot(event.snapshot);
  }

  /// Load data from database and return a [ChatRoomModel] from a group chat room id.
  ///
  /// Warning, this is for group chat only.
  ///
  static Future<ChatRoomModel> get(String id) {
    final ref = ChatService.instance.roomsRef.child(id);
    return fromReference(ref);
  }

  /// Return uid list of chat room members except mine.
  ///
  /// Don't return the uid if the user unsubscribed the chat room.
  Future<List<String>> getOtherUids() async {
    return [];
  }

  /// This is for group chat only.
  /// It creates the chat room information and it read and returns. Don't think about the speed of reading the data.
  ///
  static Future<ChatRoomModel> create({
    required String name,
    required bool isGroupChat,
    required bool isOpenGroupChat,
  }) async {
    final ref = ChatService.instance.roomsRef.push();
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      'name': name,
      'isGroupChat': isGroupChat,
      'isOpenGroupChat': isOpenGroupChat,
      'createdAt': ServerValue.timestamp,
      'users': {myUid: true},
      'master': myUid,
    };
    await ref.set(data);

    return fromReference(ref);
  }

  /// 채팅방에 남아 있는 사람이 없으면, 방을 삭제한다.
  Future<void> deleteIfNoUsers() async {
    final room = await ChatRoomModel.get(id);

    if (room.users == null || room.users!.isEmpty) {
      await room.ref.remove();
    }
  }

  /// Return the first other user uid from the users list.
  String? get otherUserUid {
    return getOtherUserUidFromRoomId(id);
  }

  /// Returns the uids of the users who subscribed the chat room.
  List<String>? get getSubscribedUids {
    final List<String>? uids = users?.entries.fold(
      [],
      (previousValue, element) =>
          element.value ? (previousValue?..add(element.key)) : previousValue,
    );
    if (uids == null) return null;
    return uids
        .where((element) => element != FirebaseAuth.instance.currentUser!.uid)
        .toList();
  }
}
