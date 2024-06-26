import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Friend {
  static DatabaseReference get rootRef => FirebaseDatabase.instance.ref('/');

  /// [myRef] is the reference to the current user's friends list. That is /friends/{myUid}/...
  static DatabaseReference get listRef =>
      rootRef.child('friends').child(myUid!);

  ///
  static DatabaseReference receivedRef(String uid) =>
      rootRef.child('friends-request-received').child(uid).child(myUid!);

  static DatabaseReference get sentRef =>
      rootRef.child('friends-request-sent').child(myUid!);

  /// [ref] is the reference of the data in the database.
  final DatabaseReference ref;

  /// [uid] is the key of the data and it's the friend's(other user's) uid.
  /// The uid of the friend is not saved as a field, but it's saved as the key
  /// of the data.
  final String uid;

  /// [name] is the name that you give to your friend. It's not the real user's name.
  /// It's like a name how you want to call your friend. And this name is not available to the other user.
  final String name;

  Friend({
    required this.ref,
    required this.uid,
    required this.name,
  });

  /// Take note of the category node. Check the snapshot ref parent
  /// because in `post-all-summaries`, category is part of the field.
  /// Since this model is shared by `post-all-summary` and `post-summary`,
  /// we need to check if category is included in the snapshot.
  factory Friend.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot.exists == false) {
      throw FireFlutterException('Friend.fromSnapshot/snapshot-not-exists',
          'Friend.fromSnapshot: snapshot does not exist');
    }
    final value = snapshot.value as Map<String, dynamic>;
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
    final snapshotReject = await sentRef.child(uid).get();
    if (snapshotReject.exists) {
      toast(context: context, message: "You have requested already");
      return;
    }

    await sentRef.child(uid).set({
      'createdAt': ServerValue.timestamp,
      'rejectedAt': 0,
      'name': '',
    });

    await receivedRef(uid).set({
      'createdAt': ServerValue.timestamp,
      'rejectedAt': 0,
      'name': '',
    });

    toast(context: context, message: "You have send a friend requested.");
  }
}
