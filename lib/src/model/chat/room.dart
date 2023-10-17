import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

/// Room
///
/// This is the model for the chat room.
/// Don't update the property directly. The property is read-only and if you want to apply the changes, listen to the stream of the chat room document.
@JsonSerializable()
class Room {
  static CollectionReference get col => FirebaseFirestore.instance.collection('chats');

  static DocumentReference doc(roomId) => col.doc(roomId);

  final String roomId;
  final String name;

  /// [rename] Each user can rename the room. This map holds the rename of the room.

  final Map<String, String> rename;
  final bool group;
  final bool open;
  final String master;
  final List<String> users;
  final List<String> moderators;
  final List<String> blockedUsers;

  final int maximumNoOfUsers;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  final Message? lastMessage;

  /// This will be false if the room does not exists on the firestore server.
  ///
  /// Use this to check if the room exists or not after calling [get] method.
  // bool exists = true;

  /// my rooms
  ///
  /// example
  /// ```
  /// Room.myRooms.snapshots().listen( ... )
  /// ```
  static Query get myRooms => col.where('users', arrayContains: myUid);

  Room({
    required this.roomId,
    required this.name,
    this.rename = const {},
    required this.group,
    required this.open,
    required this.master,
    required this.users,
    this.moderators = const [],
    this.blockedUsers = const [],
    required this.maximumNoOfUsers,
    required this.createdAt,
    this.lastMessage,
  });

  bool get isSingleChat => users.length == 2 && group == false;
  bool get isGroupChat => group;

  CollectionReference get messagesCol => roomRef(roomId).collection('messages');
  DocumentReference get ref => roomRef(roomId);

  factory Room.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Room.fromJson(
      documentSnapshot.data() as Map<String, dynamic>,
    );
  }

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  @Deprecated('Use fromJson instead')
  factory Room.fromMap({required Map<String, dynamic> map}) {
    return Room.fromJson(map);
  }

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'name': name,
      'rename': rename,
      'group': group,
      'open': open,
      'master': master,
      'users': users,
      'moderators': moderators,
      'blockedUsers': blockedUsers,
      'maximumNoOfUsers': maximumNoOfUsers,
      'createdAt': createdAt,
    };
  }

  /// Get chat room
  ///
  /// Note, this will produce a missing or insufficient permission error if
  ///   - the room does not exists.
  ///   - the user does not have permission to read the room. (he is not a member of the chat room)
  /// This error is handled on parent, but if you enable "All Exception" on the VSCode debugger,
  /// you will see the error.
  static Future<Room> get(String roomId) async {
    final snapshot = await roomDoc(roomId).get();
    if (snapshot.exists == false) throw Exception("document-not-found");
    return Room.fromDocumentSnapshot(snapshot);
  }

  /// Creates a chat room and returns the chat room.
  ///
  /// Chat room must be created by this method only.
  ///
  /// [otherUserUid] If [otherUserUid] is set, it will create a 1:1 chat. Or it will create a group chat.
  /// [open] If [open] is set, it will create an open chat room. Or it will create a private chat room.
  /// [name] If [name] is set, it will create a chat room with the given name. Or it will create a chat room with empty name.
  /// [maximumNoOfUsers] If [maximumNoOfUsers] is set, it will create a chat room with the given maximum number of users. Or it will create a chat room with no limit.
  static Future<Room> create({
    String? name,
    String? otherUserUid,
    bool open = false,
    int? maximumNoOfUsers,
  }) async {
    // prepare

    bool isSingleChat = otherUserUid != null;
    List<String> users = [myUid!];
    if (isSingleChat) users.add(otherUserUid);

    final roomId = isSingleChat ? ChatService.instance.getSingleChatRoomId(otherUserUid) : chatCol.doc().id;

    // room data
    final roomData = toCreate(
      roomId: roomId,
      master: myUid!,
      name: name,
      group: !isSingleChat,
      open: open,
      users: users,
      maximumNoOfUsers: maximumNoOfUsers ?? (isSingleChat ? 2 : ChatService.instance.maximumNoOfUsers),
    );

    // create
    await chatCol.doc(roomId).set(roomData);

    // start
    await ChatService.instance.sendProtocolMessage(
      room: Room.fromJson(roomData),
      protocol: Protocol.chatRoomCreated.name,
      text: tr.chatRoomCreateDialog,
    );

    return Room.fromJson(roomData);
  }

  @override
  String toString() => 'Room(${toJson()})';

  static Map<String, dynamic> toCreate({
    required String roomId,
    required String master,
    String? name,
    required bool group,
    required bool open,
    required List<String> users,
    int? maximumNoOfUsers,
    bool isSingleChat = false,
  }) {
    return {
      'roomId': roomId,
      'master': myUid,
      'name': name ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'group': group,
      'open': open,
      'users': users,
      'maximumNoOfUsers': maximumNoOfUsers ?? (isSingleChat ? 2 : 100),
    };
  }

  String get otherUserUid {
    assert(users.length == 2 && group == false, "This is not a single chat room");
    return ChatService.instance.getOtherUserUid(users);
  }

  /// Add a user to the room.
  Future<void> addUser(String userUid) async {
    /// Read the chat room document to check for adding a user. (NSE: Not so expansive)
    final room = await get(roomId);

    /// Check if the user is already in the room.
    if (room.users.contains(userUid)) {
      throw Exception(Code.userAlreadyInRoom);
    }

    ///
    ///
    if (room.users.length >= room.maximumNoOfUsers) {
      throw Exception(Code.roomIsFull);
    }

    ///
    await ref.update({
      'users': FieldValue.arrayUnion([userUid])
    });
  }

  invite(String userUid) async {
    if (isSingleChat) {
      throw Exception(Code.singleChatRoomCannotInvite);
    }
    return await addUser(userUid);
  }

  Future<void> join({BuildContext? context}) async {
    await addUser(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> leave() async {
    await roomDoc(roomId).update({
      'moderators': FieldValue.arrayRemove([myUid]),
      'users': FieldValue.arrayRemove([myUid]),
    });
  }

  String get lastMessageTime {
    if (lastMessage == null) return '';
    final dt = lastMessage!.createdAt;

    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.jm().format(dt);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }
}
