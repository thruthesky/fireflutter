import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fireflutter.dart';

/// Chat message model
///
/// It is used for both of chat room message itself and chat rooms' documents.
/// See readme for details.
///
class ChatMessageModel {
  String text;
  String protocol;
  Timestamp timestamp;
  int newMessages;
  String to;
  String from;

  String get time =>
      DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toLocal().toString();

  /// Login user's firebase uid.
  String get myUid => FirebaseAuth.instance.currentUser!.uid;

  /// Other user's firebase uid.
  String get otherUid {
    return to == myUid ? from : to;
  }

  /// True if the message is sent by me or owned by me.
  bool get byMe => from == myUid;
  bool get isMine => byMe;

  /// True if the message is sent by other
  bool get byOther => !byMe;

  bool get hasNewMessage => newMessages > 0;

  bool friend;

  // DocumentReference get otherUserRoomInMyRoomListRef => myRoomsCol.doc(otherUid);

  /// Reference of this document (chat model data)
  DocumentReference? ref;

  /// See if the message has image url.
  bool get isImage {
    return isImageUrl(text);
  }

  /// See if the message is a url.
  /// App should do 'canLunch', or 'url launch' to display the url.
  bool get isUrl {
    String t = text.toLowerCase();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  /// Return true if the text has url link.
  bool get hasUrl {
    String t = text.toLowerCase();
    return t.contains('http://') || t.contains('https://');
  }

  bool get isFirebaseUpload {
    return isFirebaseStorageUrl(text);
  }

  /// Check if the message is a protocol.
  bool isProtocol(String name) {
    return protocol.contains('$name:');
  }

  /// Creates a protoceol
  ///
  /// ```dart
  /// ChatMessageModel.createProtocol('location', "${pos.latitude},${pos.longitude}"),
  /// ```
  static createProtocol(String name, [String data = '']) {
    return "$name:$data";
  }

  /// Return true if the message is not url or or image.
  bool get isText {
    return isImage == false && isUrl == false;
  }

  ChatMessageModel({
    required this.to,
    required this.from,
    required this.text,
    required this.protocol,
    required this.timestamp,
    required this.newMessages,
    required this.friend,
    required this.ref,
  });

  factory ChatMessageModel.fromJson(Map<dynamic, dynamic> json, [DocumentReference? ref]) {
    return ChatMessageModel(
      to: json['to'] ?? '',
      from: json['from'] ?? '',
      text: json['text'] ?? '',
      protocol: json['protocol'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(), // handling exception
      newMessages: json['newMessages'] ?? 0,
      friend: json['friend'] ?? false,
      ref: ref,
    );
  }

  toJson() {
    return {
      'to': to,
      'from': from,
      'text': text,
      'protocol': protocol,
      'timestamp': timestamp,
      'newMessages': newMessages,
      'friend': friend,
    };
  }

  @override
  String toString() {
    return """ChatMessageModel(${toJson()})""";
  }

  /// Deletes other user in my room list.
  Future<void> deleteRoom() {
    return Chat.myOtherRoomInfoDelete(otherUid);
    // return otherUserRoomInMyRoomListRef.delete();
  }

  /// Deletes current document.
  /// It may be a chat message or room info.
  Future<void> delete() {
    return ref!.delete();
  }

  Future<void> update(String text) {
    return ref!.set({'text': text}, SetOptions(merge: true));
  }
}
