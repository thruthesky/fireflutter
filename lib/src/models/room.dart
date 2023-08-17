import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/services/chat.service.dart';
import 'package:flutter/material.dart';

/// Room
///
/// This is the model for the chat room.
/// Don't update the property directly. The property is read-only and if you want to apply the changes, listen to the stream of the chat room document.
class Room {
  final String id;
  final String name;
  final Map<String, dynamic> rename;
  final bool group;
  final bool open;
  final String master;
  final List<String> users;
  final List<String> moderators;
  final List<String> blockedUsers;
  final Map<String, int> noOfNewMessages;
  final int maximumNoOfUsers;
  final String? password; // TODO for confirmation

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
    required this.noOfNewMessages,
    required this.maximumNoOfUsers,
    this.password,
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
        noOfNewMessages: Map<String, int>.from(map['noOfNewMessages'] ?? {}),
        maximumNoOfUsers:
            map['maximumNoOfUsers'] ?? 100, // TODO confirm where to put the config on default max no of users
        password: map['password']);
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
      'noOfNewMessages': noOfNewMessages,
      'maximumNoOfUsers': maximumNoOfUsers,
      'password': password,
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
  String toString() => 'Room(id: $id, name: $name, group: $group, open: $open, master: $master, users: $users)';

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

  Future<bool> join({BuildContext? context}) async {
    /// ! ongoing
    // show room password dialog
    if (password == null) {
      await addUser(FirebaseAuth.instance.currentUser!.uid);
      return true;
    }
    if (context != null) {
      // TODO: Error, must provide context
      final bool passwordResult = await showDialog<bool?>(
          context: context,
          builder: (context) {
            final roomPassword = TextEditingController();
            return AlertDialog(
              title: Text(name),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Password: "),
                  TextFormField(
                    controller: roomPassword,
                    decoration: const InputDecoration(
                      hintText: 'Enter Chat Room Password',
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                    child: const Text('Enter'),
                    onPressed: () {
                      if (roomPassword.text == password) Navigator.pop(context, true);
                    }),
              ],
            );
          }).then(
        (passwordResult) {
          return passwordResult ?? false;
        },
      );
      if (passwordResult) await addUser(FirebaseAuth.instance.currentUser!.uid);
      return passwordResult;
    }
    return false;
  }
}
