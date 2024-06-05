import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatMessage {
  /// Paths and Refs

  static const String node = 'chat-messages';

  static DatabaseReference rootRef = FirebaseDatabase.instance.ref();
  static DatabaseReference messagesRef({required String roomId}) =>
      rootRef.child(node).child(roomId);

  /// Variables
  String? key;

  ///
  DatabaseReference? ref;
  String? uid;
  String? text;
  String? url;
  int? order;
  int? createdAt;

  String? previewUrl;
  String? previewTitle;
  String? previewDescription;
  String? previewImageUrl;

  ChatMessage? replyTo;

  bool deleted = false;

  bool get mine {
    return uid != null && uid == FirebaseAuth.instance.currentUser?.uid;
  }

  bool get hasUrlPreview =>
      previewUrl != null &&
      previewUrl!.isNotEmpty &&
      (previewTitle != null ||
          previewDescription != null ||
          previewImageUrl != null);

  bool get other => !mine;

  DatabaseReference get roomRef => ref!.parent!;

  ChatMessage({
    this.key,
    this.ref,
    this.uid,
    this.text,
    this.url,
    this.order,
    this.createdAt,
    this.previewUrl,
    this.previewTitle,
    this.previewDescription,
    this.previewImageUrl,
    this.replyTo,
    this.deleted = false,
  });

  factory ChatMessage.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['key'] = snapshot.key;
    json['ref'] = snapshot.ref;
    return ChatMessage.fromJson(json);
  }

  /// Create a ChatMessage from a Map
  ///
  ///
  /// Example:
  /// ```dart
  /// final chatMessageData = { ... };
  /// ChatMessage.fromJson({
  ///   'key': chatMessageRef.key,
  ///   ...chatMessageData,
  /// })
  /// ```
  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) {
    return ChatMessage(
      key: json['key'] as String?,
      ref: json['ref'] as DatabaseReference?,
      uid: json['uid'] as String?,
      text: json['text'] as String?,
      url: json['url'] as String?,
      order: json['order'] as int?,
      createdAt: json['createdAt'] is int
          ? json['createdAt']

          /// If the createdAt is NOT a string, then parse it to 0.
          /// This may happen when the createdAt is a ServerValue.timestamp
          : (int.tryParse(json['createdAt'].toString()) ?? 0),
      previewUrl: json['previewUrl'] as String?,
      previewTitle: json['previewTitle'] as String?,
      previewDescription: json['previewDescription'] as String?,
      previewImageUrl: json['previewImageUrl'] as String?,
      replyTo: json['replyTo'] != null
          ? ChatMessage.fromJson(json['replyTo'])
          : null,
      deleted: json['deleted'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'ref': ref,
      'uid': uid,
      'text': text,
      'url': url,
      'createdAt': createdAt,
      'order': order,
      'previewUrl': previewUrl,
      'previewTitle': previewTitle,
      'previewDescription': previewDescription,
      'previewImageUrl': previewImageUrl,
      'replyTo': replyTo,
      'deleted': deleted,
    };
  }

  /// To string
  @override
  String toString() {
    return toJson().toString();
  }

  /// 채팅 메시지를 삭제
  ///
  ///
  Future delete() {
    return ref!.update({
      'deleted': true,
      'text': null,
      'url': null,
      'previewUrl': null,
      'previewTitle': null,
      'previewDescription': null,
      'previewImageUrl': null,
      'replyTo': null,
    });
    // return ref!.remove();
  }
}
