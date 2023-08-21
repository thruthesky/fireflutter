import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/service/chat.service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Room
///
/// This is the model for the chat room.
/// Don't update the property directly. The property is read-only and if you want to apply the changes, listen to the stream of the chat room document.
class Room with FirebaseHelper {
  final String id;
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
  // TODO - 비밀번호 업데이트. EasyExtension 의 strignMatch 로 한다.
  final String? password;

  final Timestamp createdAt;

  final Message? lastMessage;

  Room({
    required this.id,
    required this.name,
    required this.rename,
    required this.group,
    required this.open,
    required this.master,
    required this.users,
    required this.moderators,
    required this.blockedUsers,
    required this.maximumNoOfUsers,
    this.password,
    required this.createdAt,
    this.lastMessage,
  });

  bool get isSingleChat => users.length == 2 && group == false;
  bool get isGroupChat => group;

  CollectionReference get messagesCol => ChatService.instance.roomRef(id).collection('messages');
  DocumentReference get ref => ChatService.instance.roomRef(id);

  factory Room.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Room.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Room.fromMap({required Map<String, dynamic> map, required id}) {
    return Room(
      id: id,
      name: map['name'] ?? '',
      rename: map['rename'] ?? {},
      group: map['group'],
      open: map['open'],
      master: map['master'],
      users: List<String>.from((map['users'] ?? [])),
      moderators: List<String>.from(map['moderators'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      maximumNoOfUsers:
          map['maximumNoOfUsers'] ?? 100, // TODO confirm where to put the config on default max no of users
      password: map['password'],

      /// Note FieldValue happens when the docuemnt is cached locally on creation and the createdAt is not set on the remote database.
      createdAt: map['createdAt'] is FieldValue ? Timestamp.now() : map['createdAt'] ?? Timestamp.now(),
      lastMessage: map['lastMessage'] != null ? Message.fromMap(map: map['lastMessage'], id: "") : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rename': rename,
      'group': group,
      'open': open,
      'master': master,
      'users': users,
      'moderators': moderators,
      'blockedUsers': blockedUsers,
      'maximumNoOfUsers': maximumNoOfUsers,
      'password': password,
      'createdAt': createdAt,
    };
  }

  /// Creates a chat room and returns the chat room.
  ///
  /// [otherUserUid] If [otherUserUid] is set, it will create a 1:1 chat. Or it will create a group chat.
  /// [isOpen] If [isOpen] is set, it will create an open chat room. Or it will create a private chat room.
  /// [roomName] If [roomName] is set, it will create a chat room with the given name. Or it will create a chat room with empty name.
  /// [maximumNoOfUsers] If [maximumNoOfUsers] is set, it will create a chat room with the given maximum number of users. Or it will create a chat room with no limit.
  static Future<Room> create({
    String? roomName,
    String? otherUserUid,
    bool isOpen = false,
    int? maximumNoOfUsers,
  }) async {
    // prepare
    String myUid = FirebaseAuth.instance.currentUser!.uid;
    bool isSingleChat = otherUserUid != null;
    bool isGroupChat = !isSingleChat;
    List<String> users = [myUid];
    if (isSingleChat) users.add(otherUserUid);

    // room data
    final roomData = {
      'master': myUid,
      'name': roomName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'group': isGroupChat,
      'open': isOpen,
      'users': users,
      'maximumNoOfUsers': maximumNoOfUsers ?? (isSingleChat ? 2 : 100),
      'lastMessage': {
        'createdAt': FieldValue.serverTimestamp(),
        // TODO make a protocol
      }
    };

    final roomId =
        isSingleChat ? ChatService.instance.getSingleChatRoomId(otherUserUid) : ChatService.instance.chatCol.doc().id;

    await ChatService.instance.chatCol.doc(roomId).set(roomData);
    return Room.fromMap(map: roomData, id: roomId);
  }

  @override
  String toString() =>
      'Room(id: $id, name: $name, group: $group, open: $open, master: $master, users: $users, moderators: $moderators, blockedUsers: $blockedUsers, maximumNoOfUsers: $maximumNoOfUsers, password: $password, createdAt: $createdAt, lastMessage: $lastMessage)';

  String get otherUserUid {
    assert(users.length == 2 && group == false, "This is not a single chat room");
    return ChatService.instance.getOtherUserUid(users);
  }

  /// Add a user to the room.
  Future<void> addUser(String userUid) async {
    /// Read the chat room document to check for adding a user. (NSE: Not so expansive)
    final room = await ChatService.instance.getRoom(id);

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

  String get lastMessageTime {
    if (lastMessage == null) return '';
    final dt = lastMessage!.createdAt.toDate();

    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.jm().format(dt);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }
}
