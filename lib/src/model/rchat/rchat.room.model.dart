import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class RChatRoomModel {
  final DatabaseReference ref;
  String key;
  String? text;
  String? url;
  int? updatedAt;
  int? newMessage;
  bool isGroupChat;
  bool isOpenGroupChat;
  String? name;
  String? description;
  String? master;
  Map<String, bool>? users;

  /// [id] It returns the chat room id.
  ///
  /// It is the node key of the chat room like the id in `/chat-rooms/{id}`.
  /// To get the message node id for both of 1:1 chat and group chat for saving message, use [messageRoomId]
  ///
  String get id => key;

  /// [path] is the path of the chat room.
  String get path => ref.path;

  bool get isSingleChat => !isGroupChat;

  RChatRoomModel({
    required this.ref,
    required this.key,
    this.text,
    this.url,
    this.updatedAt,
    this.newMessage,
    required this.isGroupChat,
    required this.isOpenGroupChat,
    this.name,
    this.description,
    this.master,
    this.users,
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

      /// See, rchat.md#database structure
      isGroupChat: isSingleChatRoom(json['key']) == false,
      isOpenGroupChat: json['isOpenGroupChat'] ?? false,
      name: json['name'] as String?,
      description: json['description'] as String?,
      master: json['master'] as String?,
      users: json['users'] == null ? null : Map<String, bool>.from(json['users']),
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
      'description': description,
      'master': master,
      'users': users,
    };
  }

  /// toString
  @override
  String toString() {
    return 'RChatRoomModel(${toJson()})';
  }

  /// Returns a [RChatRoomModel] from a group id.
  ///
  /// Note that, single chat room ref is like /chat-rooms/uidA/uidB
  ///   while group chat room ref is like /chat-rooms/groupId.
  ///
  /// This is a factory. So, you can use it for creating a chat room model object programmatically.
  factory RChatRoomModel.fromRoomdId(String id) {
    return RChatRoomModel.fromJson({
      'key': id,
      'ref': RChat.roomsRef.child(id),
    });
  }

  // /// Returns a [RChatRoomModel] from a single chat room id.
  // factory RChatRoomModel.fromUid(String otherUserUid) {
  //   return RChatRoomModel.fromJson({
  //     'key': singleChatRoomId(otherUserUid),
  //     'ref': RChat.roomRef(singleChatRoomId(otherUserUid)),
  //     'isGroupChat': false,
  //     'isOpenGroupChat': false,
  //   });
  // }

  /// Return RChatRoomModel from a reference
  ///
  ///
  static Future<RChatRoomModel> fromReference(DatabaseReference ref) async {
    final event = await ref.once();
    if (event.snapshot.exists == false) {
      throw Exception('RChatRoomModel.fromReference: ${ref.path} does not exist.');
    }
    return RChatRoomModel.fromSnapshot(event.snapshot);
  }

  /// Load data from database and return a [RChatRoomModel] from a group chat room id.
  ///
  /// Warning, this is for group chat only.
  ///
  static Future<RChatRoomModel> get(String id) {
    final ref = RChat.roomsRef.child(id);
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
  static Future<RChatRoomModel> create({
    required String name,
    required bool isGroupChat,
    required bool isOpenGroupChat,
  }) async {
    final ref = RChat.roomsRef.push();
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

  /// Return the first other user uid from the users list.
  String? get otherUserUid {
    return getOtherUserUidFromRoomId(id);
  }

  /// Returns the uids of the users who subscribed the chat room.
  List<String>? get getSubscribedUids {
    final List<String>? uids = users?.entries.fold(
      [],
      (previousValue, element) => element.value ? (previousValue?..add(element.key)) : previousValue,
    );
    if (uids == null) return null;
    return uids.where((element) => element != myUid).toList();
  }
}
