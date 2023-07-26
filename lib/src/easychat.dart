import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easychat/easychat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EasyChat {
  // The instance of the EasyChat singleton.
  static EasyChat? _instance;
  static EasyChat get instance => _instance ??= EasyChat._();

  // The private constructor for the EasyChat singleton.
  EasyChat._();

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  CollectionReference get chatCol => FirebaseFirestore.instance.collection('easychat');
  CollectionReference messageCol(String roomId) => chatCol.doc(roomId).collection('messages');

  DocumentReference get myDoc => FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
  DocumentReference roomDoc(String roomId) => chatCol.doc(roomId);

  late final String usersCollection;
  late final String displayNameField;
  late final String photoUrlField;

  final Map<String, UserModel> _userCache = {};

  Function(BuildContext, ChatRoomModel)? onChatRoomFileUpload;

  initialize({
    required String usersCollection,
    required String displayNameField,
    required String photoUrlField,
    Function(BuildContext, ChatRoomModel)? onChatRoomFileUpload,
  }) {
    this.usersCollection = usersCollection;
    this.displayNameField = displayNameField;
    this.photoUrlField = photoUrlField;
    this.onChatRoomFileUpload = onChatRoomFileUpload;
  }

  /// Get user
  ///
  /// It does memory cache.
  Future<UserModel?> getUser(String uid) async {
    if (_userCache.containsKey(uid)) return _userCache[uid];
    final snapshot = await FirebaseFirestore.instance.collection(usersCollection).doc(uid).get();
    if (!snapshot.exists) return null;
    final user = UserModel.fromDocumentSnapshot(snapshot);
    _userCache[uid] = user;
    return _userCache[uid];
  }

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
    final snapshot = await roomDoc(roomId).get();
    return ChatRoomModel.fromDocumentSnapshot(snapshot);
  }

  /// Get Chat room if exists, create the chatroom if not exist yet
  Future<ChatRoomModel> getOrCreateSingleChatRoom(String uid) async {
    try {
      return await EasyChat.instance.getSingleChatRoom(uid);
    } on FirebaseException {
      return await EasyChat.instance.createChatRoom(
        otherUserUid: uid,
      );
    }
  }

  /// Create chat room
  ///
  /// If [otherUserUid] is set, it is a 1:1 chat. If it is unset, it's a group chat.
  Future<ChatRoomModel> createChatRoom({
    String? roomName,
    String? otherUserUid,
    bool isOpen = false,
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
      'lastMessage': {
        'createdAt': FieldValue.serverTimestamp(),
        // TODO make a protocol
      }
    };

    // chat room id
    final roomId = isSingleChat ? getSingleChatRoomId(otherUserUid) : chatCol.doc().id;
    await chatCol.doc(roomId).set(roomData);

    return ChatRoomModel.fromMap(map: roomData, id: roomId);
  }

  Future<void> inviteUser({required ChatRoomModel room, required UserModel user}) async {
    await roomDoc(room.id).update({
      'users': FieldValue.arrayUnion([user.uid])
    });
  }

  Future<void> joinRoom({required ChatRoomModel room}) async {
    await roomDoc(room.id).update({
      'users': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> leaveRoom({required ChatRoomModel room, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid]),
      'users': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> removeUserFromRoom({required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid]),
      'users': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  Future<void> setUserAsModerator({required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayUnion([uid])
    });
    callback?.call();
  }

  Future<void> removeUserAsModerator({required ChatRoomModel room, required String uid, Function()? callback}) async {
    await roomDoc(room.id).update({
      'moderators': FieldValue.arrayRemove([uid])
    });
    callback?.call();
  }

  /// Return true if the uid is one of the moderators.
  isModerator({required ChatRoomModel room, required String uid}) {
    return room.moderators.contains(uid);
  }

  /// Return true if the uid is the master
  isMaster({required ChatRoomModel room, required String uid}) {
    return room.master == uid;
  }

  /// Is the user is master or moderator of the room?
  isAdmin(ChatRoomModel room) {
    return room.master == uid || room.moderators.contains(uid);
  }

  /// Check if user can be removed in the group
  ///
  canRemove({required ChatRoomModel room, required String userUid}) {
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

  canSetUserAsModerator({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: uid)) return false;

    // If the user to set as moderator is not a master allow
    if (!isMaster(room: room, uid: userUid)) return true;

    return false;
  }

  canRemoveUserAsModerator({required ChatRoomModel room, required String userUid}) {
    // If the current user is not a master, don't allow
    if (!isMaster(room: room, uid: uid)) return false;

    // If the user is a moderator, can remove
    if (isModerator(room: room, uid: userUid)) return true;

    return false;
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
    };
    await messageCol(room.id).add(chatMessage);
    updateRoomNewMessagesDetails(room: room, lastMessage: chatMessage);
  }

  Future<void> updateRoomNewMessagesDetails({required ChatRoomModel room, Map<String, Object>? lastMessage}) async {
    Map<Object, Object> updateNoOfMessages = {};
    for (var uid in room.users) {
      updateNoOfMessages[uid] = FieldValue.increment(1);
    }
    updateNoOfMessages[FirebaseAuth.instance.currentUser!.uid] = 0;
    // TODO separate noOfMessages into different collection, because of reads
    await roomDoc(room.id).set({'noOfNewMessages': updateNoOfMessages, 'lastMessage': lastMessage}, SetOptions(merge: true));
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
    return await getUser(otherUserUid);
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
      room = await EasyChat.instance.getOrCreateSingleChatRoom(user.uid);
    }

    if (context.mounted) {
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) {
          return Scaffold(
            appBar: ChatRoomAppBar(room: room!),
            body: Column(
              children: [
                Expanded(
                  child: ChatMessagesListView(
                    room: room,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const Divider(height: 0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChatRoomMessageBox(room: room),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    final re = await showModalBottomSheet<FileSource>(
        context: context,
        builder: (_) => ChatRoomFileUploadBottomSheet(
            room: room)); // For confirmation () removed Image source because we dont have FileSource
    if (re == null) return; // double check

    debugPrint("re: $re");

    if (re == FileSource.gallery || re == FileSource.camera) {
      ImageSource imageSource = re == FileSource.gallery ? ImageSource.gallery : ImageSource.camera;
      onPressedPhotoOption(room: room, imageSource: imageSource);
    } else if (re == FileSource.file) {
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
    final storageName = sanitizeFilename('${DateTime.now().millisecondsSinceEpoch}-${pickedFile.name}', replacement: '-');
    final fileName = sanitizeFilename(pickedFile.name, replacement: '-');
    onFileUpload(room: room, file: file, isImage: false, fileStorageName: storageName, fileName: fileName);
  }

  onFileUpload({
    required ChatRoomModel room,
    required File file,
    bool isImage = true,
    // TODO ask if we need to have a plugin or a simple way to check what type of file
    String? fileName,
    String? fileStorageName,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("easychat/${EasyChat.instance.uid}/$fileStorageName");
    try {
      await fileRef.putFile(file);
      final url = await fileRef.getDownloadURL();
      isImage
          ? EasyChat.instance.sendMessage(room: room, imageUrl: url)
          : EasyChat.instance.sendMessage(room: room, fileUrl: url, fileName: fileName);
    } on FirebaseException catch (e) {
      // TODO provide a way of displaying error emssage nicley
      print(e);
    }
  }
}
