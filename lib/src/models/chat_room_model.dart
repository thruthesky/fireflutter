import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/src/services/chat.service.dart';

/// ChatRoomModel
///
/// This is the model for the chat room.
/// Don't update the property directly. The property is read-only and if you want to apply the changes, listen to the stream of the chat room document.
class ChatRoomModel {
  final String id;
  final String name;
  final bool group;
  final bool open;
  final String master;
  final List<String> users;
  final List<String> moderators;
  final List<String> blockedUsers;
  final Map<String, int> noOfNewMessages;
  final int maximumNoOfUsers;

  ChatRoomModel({
    required this.id,
    required this.name,
    required this.group,
    required this.open,
    required this.master,
    required this.users,
    required this.moderators,
    required this.blockedUsers,
    required this.noOfNewMessages,
    required this.maximumNoOfUsers,
  });

  bool get isSingleChat => users.length == 2 && group == false;
  bool get isGroupChat => group;

  CollectionReference get messagesCol => ChatService.instance.roomRef(id).collection('messages');
  DocumentReference get ref => ChatService.instance.roomRef(id);

  factory ChatRoomModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return ChatRoomModel.fromMap(
        map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory ChatRoomModel.fromMap({required Map<String, dynamic> map, required id}) {
    return ChatRoomModel(
      id: id,
      name: map['name'] ?? '',
      group: map['group'],
      open: map['open'],
      master: map['master'],
      users: List<String>.from((map['users'] ?? [])),
      moderators: List<String>.from(map['moderators'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      noOfNewMessages: Map<String, int>.from(map['noOfNewMessages'] ?? {}),
      maximumNoOfUsers: map['maximumNoOfUsers'],
    );
  }

  @Deprecated(
      "Don't use this. It's useless function. Listen the document instead. Or use replaceWith()")
  update(Map<String, dynamic> updates) {
    return ChatRoomModel(
      id: id,
      name: updates['name'] ?? name,
      group: updates['group'] ?? group,
      open: updates['open'] ?? open,
      master: updates['master'] ?? master,
      users: List<String>.from((updates['users'] ?? users)),
      moderators: List<String>.from(updates['moderators'] ?? moderators),
      blockedUsers: List<String>.from(updates['blockedUsers'] ?? blockedUsers),
      noOfNewMessages: Map<String, int>.from(updates['noOfNewMessages'] ?? noOfNewMessages),
      maximumNoOfUsers:
          updates.containsKey('maximumNoOfUsers') ? updates['maximumNoOfUsers'] : maximumNoOfUsers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'group': group,
      'open': open,
      'master': master,
      'users': users,
      'moderators': moderators,
      'blockedUsers': blockedUsers,
      'noOfNewMessages': noOfNewMessages,
      'maximumNoOfUsers': maximumNoOfUsers,
    };
  }

  /// Creates a chat room and returns the chat room.
  ///
  /// [otherUserUid] If [otherUserUid] is set, it will create a 1:1 chat. Or it will create a group chat.
  /// [isOpen] If [isOpen] is set, it will create an open chat room. Or it will create a private chat room.
  /// [roomName] If [roomName] is set, it will create a chat room with the given name. Or it will create a chat room with empty name.
  /// [maximumNoOfUsers] If [maximumNoOfUsers] is set, it will create a chat room with the given maximum number of users. Or it will create a chat room with no limit.
  static Future<ChatRoomModel> create({
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

    final roomId = isSingleChat
        ? ChatService.instance.getSingleChatRoomId(otherUserUid)
        : ChatService.instance.chatCol.doc().id;

    await ChatService.instance.chatCol.doc(roomId).set(roomData);
    return ChatRoomModel.fromMap(map: roomData, id: roomId);
  }

  @override
  String toString() =>
      'ChatRoomModel(id: $id, name: $name, group: $group, open: $open, master: $master, users: $users)';

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
      throw Exception(Error.userAlreadyInRoom);
    }

    ///
    ///
    if (room.users.length >= room.maximumNoOfUsers) {
      throw Exception(Error.roomIsFull);
    }

    ///
    await ref.update({
      'users': FieldValue.arrayUnion([userUid])
    });
  }

  invite(String userUid) async {
    if (isSingleChat) {
      throw Exception(Error.singleChatRoomCannotInvite);
    }
    return await addUser(userUid);
  }

  join() async {
    return await addUser(FirebaseAuth.instance.currentUser!.uid);
  }
}
