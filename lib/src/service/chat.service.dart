import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/activity_log.functions.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ///
  ChatService._();

  ChatCustomize customize = ChatCustomize();

  /// [maximumNoOfUsers] is the maximum number of users in a group chat room.
  ///
  /// The default value is 500 and can be reset by [ChatService.instance.init]
  int maximumNoOfUsers = 500;

  /// Last message of the chat room
  ///
  /// This is used for tracking the profile display order of the chat messages.
  ///
  /// When the user opens the chat room, this will be reset to the last message
  /// of the current chat room. And this will be updated when any user sends
  /// a message in chat room list view, since that will be the last message of
  /// the chat room.
  ///
  /// This is used to keep track of last user who sent message to check if the
  /// user has changed from previous message. So the app can optionally display
  /// the user avatar in the chat room list view.
  Message? lastMessage;

  bool uploadFromCamera = true;
  bool uploadFromGallery = true;
  bool uploadFromFile = true;

  final BehaviorSubject<int> totalNoOfNewMessageChanges = BehaviorSubject.seeded(0);

  StreamSubscription? totalNoOfNewMessageSubscription;

  init({
    int maximumNoOfUsers = 500,
    bool uploadFromGallery = true,
    bool uploadFromCamera = true,
    bool uploadFromFile = true,
    bool listenTotalNoOfNewMessage = true,
    ChatCustomize? customize,
  }) {
    this.maximumNoOfUsers = maximumNoOfUsers;

    this.uploadFromGallery = uploadFromGallery;
    this.uploadFromCamera = uploadFromCamera;
    this.uploadFromFile = uploadFromFile;

    if (customize != null) {
      this.customize = customize;
    }

    if (listenTotalNoOfNewMessage) {
      /// change user on login/logout
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          totalNoOfNewMessageChanges.add(0);
          return;
        }

        totalNoOfNewMessageSubscription?.cancel();
        totalNoOfNewMessageSubscription = rtdb.ref('chats/noOfNewMessages/${user.uid}').onValue.listen((event) {
          final data = event.snapshot.value;
          if (data == null) {
            totalNoOfNewMessageChanges.add(0);
            return;
          }
          int no = 0;

          (data as Map).entries.map((e) => e.value).forEach((v) {
            no += int.tryParse(v.toString()) ?? 0;
          });

          totalNoOfNewMessageChanges.add(no);
        });
      });
    }
  }

  getSingleChatRoomId(String? otherUserUid) {
    if (otherUserUid == null) return null;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final uids = [currentUserUid, otherUserUid];
    uids.sort();
    return uids.join('-');
  }

  /// Get a chat room with the given user uid (1:1 chat)
  ///
  /// See [Room.get] for details for missing or insufficient permission error.
  Future<Room> getSingleChatRoom(String uid) async {
    final roomId = getSingleChatRoomId(uid);
    return await Room.get(roomId);
  }

  /// Get Chat room if exists, or create the chatroom if not exist yet and return it.
  ///
  /// See [Room.get] for details for missing or insufficient permission error.
  Future<Room> getOrCreateSingleChatRoom(String uid) async {
    try {
      return await ChatService.instance.getSingleChatRoom(uid);
    } on FirebaseException {
      return await Room.create(
        otherUserUid: uid,
      );
    } catch (e) {
      if (e.toString().contains('document-not-found')) {
        return await Room.create(
          otherUserUid: uid,
        );
      }
      rethrow;
    }
  }

  /// Returns a chat room module with the given chat room id.
  ///
  /// See [Room.get] for details for missing or insufficient permission error.
  @Deprecated('Use Room.get() instead')
  Future<Room> getRoom(String roomId) async {
    return await Room.get(roomId);
  }

  /// Creates a chat room and returns the chat room.
  ///
  /// [otherUserUid] If [otherUserUid] is set, it will create a 1:1 chat. Or it will create a group chat.
  /// [isOpen] If [isOpen] is set, it will create an open chat room. Or it will create a private chat room.
  /// [roomName] If [roomName] is set, it will create a chat room with the given name. Or it will create a chat room with empty name.
  /// [maximumNoOfUsers] If [maximumNoOfUsers] is set, it will create a chat room with the given maximum number of users. Or it will create a chat room with no limit.
  // Future<Room> createChatRoom({
  //   String? roomName,
  //   String? otherUserUid,
  //   bool isOpen = false,
  //   int? maximumNoOfUsers,
  // }) async {
  //   return Room.create(
  //     name: roomName,
  //     otherUserUid: otherUserUid,
  //     open: isOpen,
  //     maximumNoOfUsers: maximumNoOfUsers,
  //   );
  // }

  Future<void> removeUserFromRoom({required Room room, required String uid, Function()? callback}) async {
    await roomDoc(room.roomId).update({
      'moderators': FieldValue.arrayRemove([uid]),
      'users': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> setUserAsModerator({required Room room, required String uid, Function()? callback}) async {
    await roomDoc(room.roomId).update({
      'moderators': FieldValue.arrayUnion([uid])
    });
    callback?.call();
  }

  Future<void> removeUserAsModerator({required Room room, required String uid, Function()? callback}) async {
    await roomDoc(room.roomId).update({
      'moderators': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> addToBlockedUsers({required Room room, required String userUid, Function()? callback}) async {
    await roomDoc(room.roomId).update({
      'blockedUsers': FieldValue.arrayUnion([userUid])
    });
    callback?.call();
  }

  Future<void> removeToBlockedUsers({required Room room, required String uid, Function()? callback}) async {
    await roomDoc(room.roomId).update({
      'blockedUsers': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  /// Return true if the uid is one of the moderators.
  bool isModerator({required Room room, required String uid}) {
    return room.moderators.contains(uid);
  }

  /// Return true if the uid is the master
  bool isMaster({required Room room, required String uid}) {
    return room.master == uid;
  }

  /// Is the user is master or moderator of the room?
  bool isAdmin(Room room) {
    return room.master == myUid || room.moderators.contains(myUid);
  }

  bool isBlocked({required Room room, required String uid}) {
    return room.blockedUsers.isNotEmpty && room.blockedUsers.contains(uid);
  }

  /// Check if user can be removed in the group
  ///
  bool canRemove({required Room room, required String userUid}) {
    // One cannot remove himself
    if (userUid == myUid) return false;

    // Only master and moderator can remove
    if (isAdmin(room)) {
      // admin cannot remove the master or moderators
      if (isMaster(room: room, uid: userUid)) return false;
      if (isModerator(room: room, uid: userUid)) return false;
      return true;
    }

    return false;
  }

  bool canSetUserAsModerator({required Room room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: myUid!)) return false;

    // If the user to set as moderator is not a master, and the user is not a moderator yet, allow
    if (!isMaster(room: room, uid: userUid) && !isModerator(room: room, uid: userUid)) return true;

    return false;
  }

  bool canRemoveUserAsModerator({required Room room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: myUid!)) return false;

    // If the user is a moderator, can remove
    if (isModerator(room: room, uid: userUid)) return true;

    return false;
  }

  bool canBlockUserFromGroup({required Room room, required String userUid}) {
    // If the current user is not a admin, don't allow
    if (!isAdmin(room)) return false;

    // If the target user is not a master, don't allow
    if (isMaster(room: room, uid: userUid)) return false;

    // If the target user is not currently blocked, allow blocking
    if (!isBlocked(room: room, uid: userUid)) return true;

    return false;
  }

  bool canUnblockUserFromGroup({required Room room, required String userUid}) {
    // If the current user is not a admin, don't allow
    if (!isAdmin(room)) return false;

    // If the target user is currently blocked, allow blocking
    if (isBlocked(room: room, uid: userUid)) return true;

    return false;
  }

  Future<void> updateRoomSetting({required Room room, required String setting, required dynamic value}) async {
    if (value == null || value == '') {
      await roomDoc(room.roomId).update({setting: FieldValue.delete()});
      return;
    }
    await roomDoc(room.roomId).set({setting: value}, SetOptions(merge: true));
  }

  /// Updates the a room setting on own side.
  ///
  /// This will clear the setting if the [value] is null
  Future<void> updateMyRoomSetting({required Room room, required String setting, required dynamic value}) async {
    if (value == null || value == '') {
      await roomDoc(room.roomId).update({'$setting.${myUid!}': FieldValue.delete()});
      return;
    }
    await ChatService.instance.updateRoomSetting(
      room: room,
      setting: setting,
      value: {myUid!: value},
    );
  }

  Future<void> sendMessage({
    required Room room,
    String? text,
    String? url,
    String? protocol,
  }) async {
    if (text == null && url == null && protocol == null) return;

    final chatMessage = {
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      if (protocol != null) 'protocol': protocol,
      'createdAt': FieldValue.serverTimestamp(),
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'isUserChanged': lastMessage?.uid != myUid!,
    };
    final ref = await messageCol(room.roomId).add(chatMessage);

    /// Update url preview
    final model = UrlPreviewModel();
    await model.load(text ?? '');

    if (model.hasData) {
      final data = {
        'previewUrl': model.firstLink!,
        if (model.title != null) 'previewTitle': model.title,
        if (model.description != null) 'previewDescription': model.description,
        if (model.image != null) 'previewImageUrl': model.image,
      };
      await ref.update(data);
    }

    // ActivityService.instance.onChatMessageSent(room);

    /// * This must be called with "await". Or unit tests may fail.
    await updateRoom(room: room, lastMessage: chatMessage);
  }

  /// Send a welcome message to himeself
  ///
  /// Purpose: When a user registers, send a message to himself by creating a 1:1 chat room with admin user.
  ///
  /// Welcome message is a chat message with the protocol 'welcome' with the given message.
  /// Since it is a message to himself, it will display 1 as no of new message.
  // Future<void> sendWelcomeMessage({required room, required String message, String? protocol}) async {
  //   await sendMessage(room: room, protocol: protocol, text: message);
  //   return;
  // }

  /// Send a protocol message to chat room
  ///
  /// Any member can send a protocol message to his chat room.
  ///
  /// Example;
  /// - When a user registers, send a welcome message to the user. See [UserService.instance.sendWelcomeMessage]
  /// - When a user creates a chat room, send a chat room creation protocol message to the chat room. See [Room.create]
  ///
  Future<void> sendProtocolMessage({required Room room, required String protocol, String? text}) async {
    await sendMessage(room: room, protocol: protocol, text: text);
  }

  /// Update no of new message for all users in the room
  ///
  /// See "# No of new message" in README
  Future<void> updateRoom({
    required Room room,
    Map<String, Object>? lastMessage,
  }) async {
    //
    await roomDoc(room.roomId).set(
      {'lastMessage': lastMessage},
      SetOptions(merge: true),
    );

    // Increase the no of new message for each user in the room

    // ! potential bug here @thruthesky
    // - When users come and go, the room users change. But this room.users is not updated when the room users change.
    // - When a user enters group chat, the group chat room document passed to messgae input box widget and it is not being updated.
    // - Suggestions: convert firestore to rtdb for chat room and re-work.
    for (String uid in room.users) {
      if (uid == myUid) {
        noOfNewMessageRef(uid: uid).update({room.roomId: 0});
      } else {
        noOfNewMessageRef(uid: uid).update({room.roomId: ServerValue.increment(1)});
      }
    }
  }

  /// Reset my "no of new message" to 0 for the chat room
  Future<void> resetNoOfNewMessage({required Room room}) async {
    noOfNewMessageRef(uid: myUid!).update({room.roomId: 0});
  }

  /// Get other user uid
  ///
  /// ! If there is no other user uid, it will return current user's uid. This is because one can chat with himself.
  String getOtherUserUid(List<String> users) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    // Must review
    if (currentUserUid == null) {
      throw Exception('Unable to get other user uid because the currentUserUid is null. User must be logged in.');
    }
    return users.firstWhere(
      (uid) => uid != currentUserUid,
      orElse: () => currentUserUid,
    );
  }

  Future<User?> getOtherUserFromSingleChatRoom(Room room) async {
    final otherUserUid = getOtherUserUid(room.users);
    return await UserService.instance.get(otherUserUid);
  }

  /// Open Chat Room
  ///
  /// When the user taps on a chat room, this method is called to open the chat room.
  /// When the login user taps on a user NOT a chat room, then the user want to chat 1:1. That's why the user tap on the user.
  /// In this case, search if there is a chat room the method checks if the 1:1 chat room exists or not.
  Future showChatRoom({
    required BuildContext context,
    Room? room,
    User? user,
    String? setMessage,
  }) async {
    assert(
      room != null || user != null,
      "One of room or user must be not null",
    );

    log('---> showChatRoom: room: $room, user: $user');

    /// log chat open
    activityLogUserRoomOpen(roomId: room?.roomId, otherUid: user?.uid);

    if (context.mounted) {
      if (customize.showChatRoom != null) {
        return customize.showChatRoom?.call(context: context, room: room, user: user);
      }
      return showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return ChatRoomScreen(
            room: room,
            user: user,
            setMessage: setMessage,
          );
        },
      );
    }
  }

  /// Show create chat room dialog
  ///
  /// Note, it does not close the chat creation dialog.
  Future showCreateChatRoomDialog(
    BuildContext context, {
    required void Function(Room room) success,
    required void Function() cancel,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => ChatRoomCreateDialog(
        success: success,
        cancel: cancel,
      ),
    );
  }

  /// Opens the chat room menu
  openChatRoomMenuDialog({required Room room, required BuildContext context}) {
    return showDialog(
      context: context,
      builder: (context) {
        return ChatRoomMenuScreen(
          room: room,
        );
      },
    );
  }

  clearLastMessage() {
    lastMessage = null;
  }

  setLastMessage(Message message) {
    if (message.createdAt.microsecondsSinceEpoch > (lastMessage?.createdAt.microsecondsSinceEpoch ?? 0)) {
      lastMessage = message;
    }
  }
}
