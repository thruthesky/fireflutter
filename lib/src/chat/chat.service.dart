import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

import 'package:rxdart/rxdart.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ?? (_instance = ChatService());

  /// The user that the signed-in-user chatting with on the chat room.
  /// If signed-in-user leaves the chat room, this value becomes null.
  UserModel? otherUser;

  /// Post [newMessages] event when there is a new message.
  ///
  /// Use this event to update the no of new chat messagges.
  /// * The app should unsubscribe [newMessages] if it is not used for life time.
  BehaviorSubject<int> newMessages = BehaviorSubject.seeded(0);

  /// Observe and update no of new messages.
  int noOfNewMessages = 0;

  StreamSubscription? roomSubscription;

  /// Room info document must be updated. Refer readme.
  ///
  /// Update my friend under
  ///   - /chat/rooms/<my-uid>/<other-uid>
  /// To make sure, all room info doc update must use this method.
  Future<void> myOtherRoomInfoUpdate(String otherUid, Map<String, dynamic> data) {
    return ChatBase.myRoomsCol.doc(otherUid).set(data, SetOptions(merge: true));
  }

  /// Room info document must be updated. Refer readme.
  ///
  /// Update my info under my friend's room list
  ///   - /chat/rooms/<other-uid>/<my-uid>
  /// To make sure, all room info doc update must use this method.
  Future<void> otherMyRoomInfoUpdate(String otherUid, Map<String, dynamic> data) {
    return ChatBase.otherRoomsCol(otherUid).doc(ChatBase.myUid).set(data, SetOptions(merge: true));
  }

  /// Counting new messages
  ///
  /// Call this method to count the number of new messages.
  ///
  /// Note, the subcriptions should be re-subscribe when user change accounts.
  /// Note, you may unsubscribe on your needs.
  ///
  ///
  countNewMessages() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        log('unsubscribeNewMessages');
        unsubscribeNewMessages();
      } else {
        log('unsubscribeNewMessages');
        subscribeNewMessages();
      }
    });
  }

  subscribeNewMessages() {
    if (roomSubscription != null) roomSubscription!.cancel();
    roomSubscription =
        ChatBase.myRoomsCol.where('newMessages', isGreaterThan: 0).snapshots().listen((QuerySnapshot snapshot) {
      // print('countNewMessages() ... listen()');
      noOfNewMessages = 0;
      snapshot.docs.forEach((doc) {
        ChatMessageModel room = ChatMessageModel.fromJson(doc.data() as Map, null);
        noOfNewMessages += room.newMessages;
      });
      newMessages.add(noOfNewMessages);
    });
  }

  /// Unsubscribe for what `countNewMessages()` subscribed and
  /// update the number of new message to 0.
  ///
  /// The reason why it is posting 0 in [newMessage] event is to remove the badge.
  /// Or to remove the number of new chat message on profile if ever.
  /// Normally there will be a badge on user's profile and if the newMessage is 0,
  /// it should not display badge.
  unsubscribeNewMessages() {
    roomSubscription?.cancel();
    noOfNewMessages = 0;
    newMessages.add(0);
  }

  /// Send a chat message
  /// It sends the chat message even if the login user is not in chat room.
  ///
  /// Important note that, this method updates 3 documents.
  ///   - /chat/rooms/<my>/<other>
  ///   - /chat/rooms/<other>/<my>
  ///   - /chat/messages/<uid>-<uid>
  ///   And if you update /chat/rooms/... in other place while sending a message,
  ///   then, document will be updated twice and listener handlers will be called twice
  ///   then, the screen may be flickering.
  ///   So, it has options to update myOtherData for `/chat/rooms/<my>/<other>`
  ///     and otherMyData for `/chat/rooms/<other>/<my>`.
  ///     with this, you can update the room info docs and you don't have to
  ///     update `/chat/rooms/...` separately.
  ///
  ///
  /// Use case;
  ///   - send a message to B when A likes B's post.
  ///   - send a message to B when A request friend map to B.
  ///
  /// [cleaerNewMessage] should be true only when the login user is inside the room or entering the room.
  ///   - if the user is not inside the room, and simply send a message to a user without entering the room,
  ///     then this should be false, meaning, it does not reset the no of new message.
  ///   - so, this option is only for logged in user.
  Future<Map<String, dynamic>> send({
    required String text,
    String? protocol,
    required String otherUid,
    bool clearNewMessage: true,
    Map<String, dynamic> myOtherData = const {},
    Map<String, dynamic> otherMyData = const {},
  }) async {
    final data = {
      'text': text,
      if (protocol != null) 'protocol': protocol,
      'timestamp': FieldValue.serverTimestamp(),
      'from': UserService.instance.uid,
      'to': otherUid,
    };

    /// Add a chat message under the chat room.

    await ChatBase.messagesCol(otherUid).add(data);

    /// When the login user is inside the chat room, it should clear no of new message.
    if (clearNewMessage) {
      data['newMessages'] = 0;
    }

    /// Update the room info under my chat room list,
    /// So once A sent a message to B for the first time, `B` is under A's room list.
    await myOtherRoomInfoUpdate(otherUid, {...data, ...myOtherData});

    /// count new messages and update it on the other user's room info.
    data['newMessages'] = FieldValue.increment(1);
    await otherMyRoomInfoUpdate(otherUid, {...data, ...otherMyData});
    return data;
  }

  /// throws error if there is not permission.
  Future clearNewMessages(String otherUid) {
    return myOtherRoomInfoUpdate(otherUid, {'newMessages': 0});
  }

  /// Return a room block doc under currently logged in user's block list.
  Future<DocumentSnapshot<Object?>> getBlockRoomInfo(String otherUid) {
    return ChatBase.myRoomsBlockedCol.doc(otherUid).get();
  }

  /// Return a room info doc under currently logged in user's room list.
  Future<DocumentSnapshot<Object?>> getRoomInfo(String otherUid) {
    return ChatBase.myRoomsCol.doc(otherUid).get();
  }

  /// Delete /chat/room/<my-uid>/<other-uid>
  Future<void> myOtherRoomInfoDelete(String otherUid) {
    return ChatBase.myRoomsCol.doc(otherUid).delete();
  }

  /// block a user
  Future<void> blockUser(String otherUid) {
    final futures = [
      myOtherRoomInfoDelete(otherUid),
      ChatBase.myRoomsBlockedCol.doc(otherUid).set({
        'timestamp': FieldValue.serverTimestamp(),
      }),
    ];
    return Future.wait(futures);
  }

  /// unblock a user
  Future<void> unblockUser(String otherUid) {
    // print('unblock user');
    final futures = [
      ChatBase.myRoomsCol.doc(otherUid).set({
        'from': ChatBase.myUid,
        'to': otherUid,
        'newMessage': 0,
        'text': '',
        'timestamp': FieldValue.serverTimestamp(),
      }),
      ChatBase.myRoomsBlockedCol.doc(otherUid).delete(),
    ];
    return Future.wait(futures);
  }

  /// add a user as a friend.
  Future<void> addFriend(String otherUid) async {
    final room = await ChatBase.myRoomsCol.doc(otherUid).get();
    if (room.exists) {
      return myOtherRoomInfoUpdate(otherUid, {'friend': true});
    }
    final msg = 'Hi, I am ${UserService.instance.displayName}. Can you add me as your friend?';
    await send(text: msg, otherUid: otherUid, myOtherData: {'friend': true});

    try {
      /// Send push notification from client.
      // Messaging.sendToChatUser({
      //   'title': User.displayName + ' sent a message.',
      //   'body': msg,
      //   'uids': otherUid,
      //   'badge': "1",
      //   'type': 'chat',
      //   'senderUid': _.uid,
      // });
    } catch (e) {
      print('Messaging.sendToChatUser');
      print(e);
      rethrow;
    }
  }

  /// un-friend a user
  Future<void> removeFriend(String otherUid) {
    return myOtherRoomInfoUpdate(otherUid, {'friend': false});
  }

  /// Sends push notification to the other user
  ///
  /// Check if the other user muted on me. If so, don't send the message.
  Future<DocumentReference?> sendPushNotification({
    required String title,
    required String body,
    required String uid,
  }) async {
    // final s = UserSettings(uid: uid, documentId: 'chat.$uid');
    // print('s.path; ${s.path}, my uid: ${UserService.instance.uid}');

    // int newMessages = await Chat.getNoOfNewMessages(otherUser!.uid);

    final doc = await UserSettings(uid: uid, documentId: 'chat.${UserService.instance.uid}').get();
    // print(doc);
    if (doc != null) {
      print('The user muted me. Just return.');
      return null;
    }

    return MessagingService.instance.queue(
      title: title,
      body: body,
      type: 'chat',
      badge: noOfNewMessages.toString(),
      uids: [uid],
    );
  }
}
