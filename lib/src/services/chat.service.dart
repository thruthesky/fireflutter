import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/models/chat_room_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ///
  ChatService._();

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  CollectionReference get chatCol => FirebaseFirestore.instance.collection('easychat');
  CollectionReference messageCol(String roomId) => chatCol.doc(roomId).collection('messages');

  DocumentReference roomRef(String roomId) => chatCol.doc(roomId);

  DocumentReference get myDoc =>
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
  DocumentReference roomDoc(String roomId) => chatCol.doc(roomId);

  Function(BuildContext, ChatRoomModel)? onChatRoomFileUpload;

  /// TODO: Support official localization.
  Map<String, String> texts = {};

  getSingleChatRoomId(String? otherUserUid) {
    if (otherUserUid == null) return null;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final uids = [currentUserUid, otherUserUid];
    uids.sort();
    return uids.join('-');
  }

  /// Get a chat room with the given user uid (1:1 chat)
  /// ! This will expectedly throw an error if we are trying to get a non existing record.
  Future<ChatRoomModel> getSingleChatRoom(String uid) async {
    final roomId = getSingleChatRoomId(uid);
    return getRoom(roomId);
  }

  /// Get Chat room if exists, or create the chatroom if not exist yet and return it.
  Future<ChatRoomModel> getOrCreateSingleChatRoom(String uid) async {
    try {
      return await ChatService.instance.getSingleChatRoom(uid);
    } on FirebaseException {
      return await ChatService.instance.createChatRoom(
        otherUserUid: uid,
      );
    }
  }

  /// Returns a chat room module with the given chat room id.
  Future<ChatRoomModel> getRoom(String roomId) async {
    final snapshot = await roomDoc(roomId).get();
    return ChatRoomModel.fromDocumentSnapshot(snapshot);
  }

  /// Creates a chat room and returns the chat room.
  ///
  /// [otherUserUid] If [otherUserUid] is set, it will create a 1:1 chat. Or it will create a group chat.
  /// [isOpen] If [isOpen] is set, it will create an open chat room. Or it will create a private chat room.
  /// [roomName] If [roomName] is set, it will create a chat room with the given name. Or it will create a chat room with empty name.
  /// [maximumNoOfUsers] If [maximumNoOfUsers] is set, it will create a chat room with the given maximum number of users. Or it will create a chat room with no limit.
  Future<ChatRoomModel> createChatRoom({
    String? roomName,
    String? otherUserUid,
    bool isOpen = false,
    int? maximumNoOfUsers,
  }) async {
    return ChatRoomModel.create(
      roomName: roomName,
      otherUserUid: otherUserUid,
      isOpen: isOpen,
      maximumNoOfUsers: maximumNoOfUsers,
    );
  }

  @Deprecated('Use room.invite() instead')
  Future<ChatRoomModel> inviteUser({required ChatRoomModel room, required String userUid}) async {
    // return await addUserToRoom(room: room, userUid: userUid);
    return await room.invite(userUid);
  }

  @Deprecated('Use room.join() instead')
  Future<ChatRoomModel> joinRoom({required ChatRoomModel room}) async {
    // return await addUserToRoom(room: room, userUid: uid);
    return await room.join();
  }

  /// Add user to room
  @Deprecated('Use room.addUser() instead')
  Future<ChatRoomModel> addUserToRoom(
      {required ChatRoomModel room, required String userUid}) async {
    await room.addUser(userUid);

    // if (room.users.length >= (room.maximumNoOfUsers ?? room.users.length + 1)) {
    //   throw ChatServiceException('room-is-full', 'The room is full');
    // }
    // await roomDoc(room.id).update({
    //   'users': FieldValue.arrayUnion([userUid])
    // });
    room.users.add(userUid);
    return room.update({'users': room.users});
  }

  Future<void> leaveRoom({required ChatRoomModel room, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid]),
      'users': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> removeUserFromRoom(
      {required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid]),
      'users': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> setUserAsModerator(
      {required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayUnion([uid])
    });
    callback?.call();
  }

  Future<void> removeUserAsModerator(
      {required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> addToBlockedUsers(
      {required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'blockedUsers': FieldValue.arrayUnion([uid])
    });
    callback?.call();
  }

  Future<void> removeToBlockedUsers(
      {required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'blockedUsers': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  /// Return true if the uid is one of the moderators.
  bool isModerator({required ChatRoomModel room, required String uid}) {
    return room.moderators.contains(uid);
  }

  /// Return true if the uid is the master
  bool isMaster({required ChatRoomModel room, required String uid}) {
    return room.master == uid;
  }

  /// Is the user is master or moderator of the room?
  bool isAdmin(ChatRoomModel room) {
    return room.master == uid || room.moderators.contains(uid);
  }

  bool isBlocked({required ChatRoomModel room, required String uid}) {
    return room.blockedUsers.isNotEmpty && room.blockedUsers.contains(uid);
  }

  /// Check if user can be removed in the group
  ///
  bool canRemove({required ChatRoomModel room, required String userUid}) {
    // One cannot remove himself
    if (userUid == uid) return false;

    // Only master and moderator can remove
    if (isAdmin(room)) {
      // admin cannot remove the master or moderators
      if (isMaster(room: room, uid: userUid)) return false;
      if (isModerator(room: room, uid: userUid)) return false;
      return true;
    }

    return false;
  }

  bool canSetUserAsModerator({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: uid)) return false;

    // If the user to set as moderator is not a master allow
    if (!isMaster(room: room, uid: userUid)) return true;

    return false;
  }

  bool canRemoveUserAsModerator({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: uid)) return false;

    // If the user is a moderator, can remove
    if (isModerator(room: room, uid: userUid)) return true;

    return false;
  }

  bool canBlockUserFromGroup({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a admin, don't allow
    if (!isAdmin(room)) return false;

    // If the target user is not a master, don't allow
    if (isMaster(room: room, uid: userUid)) return false;

    // If the target user is not currently blocked, allow blocking
    if (!isBlocked(room: room, uid: userUid)) return true;

    return false;
  }

  bool canUnblockUserFromGroup({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a admin, don't allow
    if (!isAdmin(room)) return false;

    // If the target user is currently blocked, allow blocking
    if (isBlocked(room: room, uid: userUid)) return true;

    return false;
  }

  Future<ChatRoomModel> updateRoomSetting(
      {required ChatRoomModel room, required String setting, required dynamic value}) async {
    await roomDoc(room.id).set({setting: value}, SetOptions(merge: true));
    return room.update({setting: value});
  }

  Future<void> sendMessage({
    required ChatRoomModel room,
    String? text,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
  }) async {
    final chatMessage = {
      if (text != null) 'text': text,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileName != null) 'fileName': fileName,
      'createdAt': FieldValue.serverTimestamp(),
      'senderUid': FirebaseAuth.instance.currentUser!.uid,
      // TODO protocol
    };
    await messageCol(room.id).add(chatMessage);
    updateRoomNewMessagesDetails(room: room, lastMessage: chatMessage);
  }

  Future<void> updateRoomNewMessagesDetails(
      {required ChatRoomModel room, Map<String, Object>? lastMessage}) async {
    Map<Object, Object> updateNoOfMessages = {};
    for (var uid in room.users) {
      updateNoOfMessages[uid] = FieldValue.increment(1);
    }
    updateNoOfMessages[FirebaseAuth.instance.currentUser!.uid] = 0;
    // TODO separate noOfMessages into different collection, because of reads
    await roomDoc(room.id).set({'noOfNewMessages': updateNoOfMessages, 'lastMessage': lastMessage},
        SetOptions(merge: true));
  }

  /// Get other user uid
  ///
  /// ! If there is no other user uid, it will return current user's uid. This is because one can chat with himself.
  String getOtherUserUid(List<String> users) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return users.firstWhere(
      (uid) => uid != currentUserUid,
      orElse: () => currentUserUid,
    );
  }

  Future<UserModel?> getOtherUserFromSingleChatRoom(ChatRoomModel room) async {
    final otherUserUid = getOtherUserUid(room.users);
    return await UserService.instance.get(otherUserUid);
  }

  /// Open Chat Room
  ///
  /// When the user taps on a chat room, this method is called to open the chat room.
  /// When the login user taps on a user NOT a chat room, then the user want to chat 1:1. That's why the user tap on the user.
  /// In this case, search if there is a chat room the method checks if the 1:1 chat room exists or not.
  showChatRoom({
    required BuildContext context,
    ChatRoomModel? room,
    UserModel? user,
  }) async {
    assert(room != null || user != null, "One of room or user must be not null");

    // If it is 1:1 chat, get the chat room. (or create if it does not exist)
    if (user != null) {
      room = await ChatService.instance.getOrCreateSingleChatRoom(user.uid);
    }

    if (context.mounted) {
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return ChatRoom(
            room: room!,
          );
        },
      );
    }
  }

  /// File upload
  ///
  /// This method is invoked when user press button to upload a file.
  onPressedFileUploadIcon({required BuildContext context, required ChatRoomModel room}) async {
    if (onChatRoomFileUpload != null) {
      await onChatRoomFileUpload!(context, room);
      return;
    }
    final re = await showModalBottomSheet<MediaSource>(
        context: context,
        builder: (_) => ChatRoomFileUploadBottomSheet(
            room:
                room)); // For confirmation () removed Image source because we dont have MediaSource
    if (re == null) return; // double check

    debugPrint("re: $re");

    if (re == MediaSource.gallery || re == MediaSource.camera) {
      ImageSource imageSource =
          re == MediaSource.gallery ? ImageSource.gallery : ImageSource.camera;
      onPressedPhotoOption(room: room, imageSource: imageSource);
    } else if (re == MediaSource.file) {
      onPressedChooseFileUploadOption(room: room);
    }
  }

  onPressedPhotoOption({required ChatRoomModel room, required ImageSource imageSource}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: imageSource);
    if (image == null) {
      return;
    }

    final file = File(image.path);
    final name = sanitizeFilename(image.name, replacement: '-');
    onFileUpload(room: room, file: file, isImage: true, fileStorageName: name);
  }

  onPressedChooseFileUploadOption({required ChatRoomModel room}) async {
    late PlatformFile pickedFile;
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    pickedFile = result.files.first;
    final file = File(pickedFile.path!);
    final storageName = sanitizeFilename(
        '${DateTime.now().millisecondsSinceEpoch}-${pickedFile.name}',
        replacement: '-');
    final fileName = sanitizeFilename(pickedFile.name, replacement: '-');
    onFileUpload(
        room: room, file: file, isImage: false, fileStorageName: storageName, fileName: fileName);
  }

  onFileUpload({
    required ChatRoomModel room,
    required File file,
    bool isImage = true,
    String? fileName,
    String? fileStorageName,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("ChatService/${ChatService.instance.uid}/$fileStorageName");
    try {
      await fileRef.putFile(file);
      final url = await fileRef.getDownloadURL();
      isImage
          ? ChatService.instance.sendMessage(room: room, imageUrl: url)
          : ChatService.instance.sendMessage(room: room, fileUrl: url, fileName: fileName);
    } on FirebaseException catch (e) {
      debugPrint('$e');
    }
  }

  showCreateChatRoomDialog(
    BuildContext context, {
    required void Function(ChatRoomModel room) success,
    required void Function() cancel,
  }) {
    showDialog(
      context: context,
      builder: (_) => ChatRoomCreate(
        success: success,
        cancel: cancel,
      ),
    );
  }
}
