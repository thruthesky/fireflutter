import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FriendsNode {
  static const String friends = 'friends';
  static const String friendsRequestReceived = 'friends-request-received';
  static const String friendsRequestSent = 'friends-request-sent';
}

class FriendField {
  static const String name = 'name';
  static const String createdAt = 'createdAt';
  static const String rejectedAt = 'rejectedAt';
  static const String acceptedAt = 'acceptedAt';
}

class Friend {
  static DatabaseReference get rootRef => FirebaseDatabase.instance.ref('/');

  /// [listRef] is the reference to a users friends list. That is /friends/{uid}/...
  static DatabaseReference listRef(String uid) =>
      rootRef.child(FriendsNode.friends).child(uid);

  /// [myListRef] is the reference to the current user's friends list.
  /// That is /friends/{myUid}/...
  static DatabaseReference get myListRef => listRef(myUid!);

  /// [myRequestListRef] is the reference to the current user's request list.
  /// That is /friends-request-received/{myUid}/...
  static DatabaseReference get myReceivedRequestListRef =>
      rootRef.child(FriendsNode.friendsRequestReceived).child(myUid!);

  /// [receivedRequestRef] is the reference of the specific request by a sender to a receiver.
  /// That is /friends-request-received/{receiverUid}/{senderUid}/...
  static DatabaseReference receivedRequestRef(
    String senderUid,
    String receiverUid,
  ) =>
      rootRef
          .child(FriendsNode.friendsRequestReceived)
          .child(receiverUid)
          .child(senderUid);

  /// [myReceivedRequestRef] is the reference to the current user's received request to other users.
  /// That is /friends-request-received/{myUid}/{senderUid}/...
  static DatabaseReference myReceivedRequestRef(String senderUid) =>
      receivedRequestRef(senderUid, myUid!);

  /// [mySentListRef] is the reference to the current user's send requests list to other users.
  /// The current user is the sender in the list.
  /// That is /friends-request-sent/{myUid}/...
  static DatabaseReference get mySentRequestListRef =>
      rootRef.child(FriendsNode.friendsRequestSent).child(myUid!);

  /// [sendRequestRef] is the reference of the specific request by a receiver to a sender.
  /// That is /friends-request-sent/{senderUid}/{receiverUid}/...
  static DatabaseReference sentRequestRef(
    String senderUid,
    String receiverUid,
  ) =>
      rootRef
          .child(FriendsNode.friendsRequestSent)
          .child(senderUid)
          .child(receiverUid);

  /// [mySentRequestRef] is the reference to a current user's sent request to other users.
  /// That is /friends-request-sent/{myUid}/{senderUid}/...
  static DatabaseReference mySentRequestRef(String receiverUid) =>
      sentRequestRef(myUid!, receiverUid);

  /// [ref] is the reference of the data in the database.
  final DatabaseReference ref;

  /// [uid] is the key of the data and it's the friend's(other user's) uid.
  /// The uid of the friend is not saved as a field, but it's saved as the key
  /// of the data.
  final String uid;

  /// [name] is the name that you give to your friend. It's not the real user's name.
  /// It's like a name how you want to call your friend. And this name is not available to the other user.
  final String name;

  final int createdAt;
  final int? rejectedAt;
  final int? acceptedAt;

  Friend({
    required this.ref,
    required this.uid,
    required this.name,
    required this.createdAt,
    required this.rejectedAt,
    required this.acceptedAt,
  });

  factory Friend.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot.exists == false) {
      throw FireFlutterException('Friend.fromSnapshot/snapshot-not-exists',
          'Friend.fromSnapshot: snapshot does not exist');
    }
    final value = Map<String, dynamic>.from(snapshot.value as Map);
    return Friend.fromJson(
      value,
      snapshot.ref,
    );
  }

  factory Friend.fromJson(
    Map<String, dynamic> json,
    DatabaseReference ref,
  ) {
    return Friend(
      ref: ref,
      uid: ref.key!,
      name: json['name'] ?? '',
      createdAt: json['createdAt'],
      rejectedAt: json['rejectedAt'],
      acceptedAt: json['acceptedAt'],
    );
  }

  ///
  update({
    String? name,
  }) {
    ref.update({
      if (name != null) 'name': name,
    });
  }

  /// Request as a friend
  ///
  /// When the user requests a friend more than once, The app should show a
  /// message of "You have requested already".
  ///
  /// And even if the user has been rejected by the friend, the app should
  /// still show a message of "You have requested already". Because most of
  /// the user don't want to be rude by showing a message of "You have been
  /// rejected".
  ///
  /// Logic:
  /// - Check if the login user has been rejected by the friend.
  /// ---> If rejected, then show a message of "You have reuqested already".
  /// ---> NOT the message of "You have been rejected".
  /// - Check if the login user has already reqeusted the friend.
  /// ---> then show a message of "You have requested already".
  static Future request({
    required BuildContext context,
    required String uid,
  }) async {
    final snapshotRequestHistory = await mySentRequestRef(uid).get();
    if (snapshotRequestHistory.exists) {
      toast(context: context, message: "You have requested already");
      return;
    }

    // TODO make it one transaction
    final requestData = {
      FriendField.createdAt: ServerValue.timestamp,
      FriendField.rejectedAt: 0,
      // 'name': '',
    };
    await mySentRequestRef(uid).set(requestData);
    await receivedRequestRef(myUid!, uid).set(requestData);

    if (!context.mounted) return;
    toast(context: context, message: "You have sent a friend request.");
  }

  /// Accept a friend request
  ///
  /// This will remove the request from current user's received request, and from other user's sent request.
  /// This will add friend dart to
  static Future<void> acceptRequest({
    required BuildContext context,
    required String uid,
  }) async {
    // TODO make it one transaction
    // await myReceivedRequestRef(uid).set(null);
    // await sentRequestRef(uid, myUid!).set(null);
    await myReceivedRequestRef(uid)
        .child(FriendField.acceptedAt)
        .set(ServerValue.timestamp);
    await sentRequestRef(uid, myUid!)
        .child(FriendField.acceptedAt)
        .set(ServerValue.timestamp);

    final newFriendData = {
      FriendField.createdAt: ServerValue.timestamp,
      // FriendField.name: '',
    };
    // Set the other person as my friend in my friend list
    await myListRef.child(uid).set(newFriendData);
    // Set myself to the other person's friend list
    await listRef(uid).child(myUid!).set(newFriendData);

    if (!context.mounted) return;
    toast(context: context, message: "You have accepted a friend request.");
  }

  static Future<void> rejectRequest({
    required BuildContext context,
    required String uid,
  }) async {
    const String rejectedAt = 'rejectedAt';
    // TODO make it one transaction
    await sentRequestRef(uid, myUid!)
        .child(rejectedAt)
        .set(ServerValue.timestamp);
    await myReceivedRequestRef(uid)
        .child(rejectedAt)
        .set(ServerValue.timestamp);
    if (!context.mounted) return;
    toast(context: context, message: "You have rejected a friend request.");
  }

  static Future<void> cancelRequest({
    required BuildContext context,
    required String uid,
  }) async {
    await mySentRequestRef(uid).set(null);
    await receivedRequestRef(myUid!, uid).set(null);

    if (!context.mounted) return;
    toast(context: context, message: "You have cancelled a friend request.");
  }
}
