import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

import 'package:fireflutter/fireflutter.dart';

class ChatService {
  static UserModel? otherUser;
  static late final ChatRoomModel currentRoom;

  // static UserModel? currentUserDetails; // For confirmation

  // For confirmation because I think we should not
  // repeatedly retrieve the NameTag and check if it is null or empty
  // static String? currentUserNameTag;

  static String get roomId {
    return getRoomId(currentRoom.otherUserUid);
  }

  static String getRoomId(String otherUserUid) {
    final uids = [UserService.uid, otherUserUid]..sort();
    return uids.join('-');
  }

  static DatabaseReference get roomRef => FirebaseDatabase.instance.ref('/chat/messages/$roomId');

  static sendMessage({String? message, String? photoUrl, required int orderNo}) async {
    final data = {
      if (message != null) 'text': message,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': ServerValue.timestamp,
      'senderUid': UserService.uid,
      'orderNo': orderNo,
    };
    await FirebaseDatabase.instance.ref('/chat/messages/$roomId').push().set(data);

    updateRoom(UserService.uid, otherUser!.uid, data);
    updateRoom(otherUser!.uid, UserService.uid, data, resetNoOfNewMessage: true);
  }

  // Is there a better way to get the User Details?
  static Future loadOtherUserDocument({String? otherUserUid}) async {
    otherUser = await UserService.getUserDocument(otherUserUid ?? currentRoom.otherUserUid);
  }

  static Future<ChatRoomModel> getRoom(String otherUserUid) async {
    final snapshot = await FirebaseDatabase.instance.ref('/chat/rooms/${UserService.uid}/$otherUserUid').get();

    return ChatRoomModel.fromSnapshot(snapshot);
  }

  static updateRoom(String uid1, String uid2, Map<String, Object> message, {bool resetNoOfNewMessage = false}) async {
    if (uid1.isEmpty || uid2.isEmpty) {
      log('Error: Uid1 or Uid2 must not be empty');
      return;
    }
    final DatabaseReference roomRef = getRoomRef(uid1, uid2);
    final roomData = {
      'noOfNewMessages': resetNoOfNewMessage ? 0 : ServerValue.increment(1),
      'lastMessage': message,
      'updatedAt': ServerValue.timestamp
    };
    // log(roomRef.toString());
    roomRef.update(roomData);
  }

  /// Used to get the room reference
  static getRoomRef(String uid1, String uid2) {
    DatabaseReference roomRef = FirebaseDatabase.instance.ref('/chat/rooms/$uid1/$uid2');
    return roomRef;
  }
}
