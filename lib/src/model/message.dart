import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Message with FirebaseHelper {
  final String id;
  final String? text;
  @override
  final String uid;

  final Timestamp createdAt;
  final String? url;
  final String? protocol;

  final String? previewUrl;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImageUrl;

  final bool isUserChanged;

  Message({
    required this.id,
    required this.text,
    required this.url,
    required this.protocol,
    required this.uid,
    required this.createdAt,
    this.previewUrl,
    this.previewTitle,
    this.previewDescription,
    this.previewImageUrl,
    required this.isUserChanged,
  });

  bool get hasUrl => url != null && url != '';
  bool get hasPreview => previewUrl != null && previewUrl != '';
  bool get isProtocol => protocol != null && protocol != '';

  factory Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Message.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Message.fromMap({required Map<String, dynamic> map, required id}) {
    return Message(
      id: id,
      text: map['text'],
      url: map['url'],
      protocol: map['protocol'],
      uid: map['uid'] ?? '',
      createdAt: (map['createdAt'] == null || map['createdAt'] is FieldValue) ? Timestamp.now() : map['createdAt'],
      previewUrl: map['previewUrl'],
      previewTitle: map['previewTitle'],
      previewDescription: map['previewDescription'],
      previewImageUrl: map['previewImageUrl'],
      isUserChanged: map['isUserChanged'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'url': url,
      'protocol': protocol,
      'uid': uid,
      'createdAt': createdAt,
      if (previewUrl != null) 'previewUrl': previewUrl,
      if (previewTitle != null) 'previewTitle': previewTitle,
      if (previewDescription != null) 'previewDescription': previewDescription,
      if (previewImageUrl != null) 'previewImageUrl': previewImageUrl,
      'isUserChanged': isUserChanged,
    };
  }

  @override
  String toString() =>
      'Message(id: $id, text: $text,  url: $url, protocol: $protocol, uid: $uid, createdAt: $createdAt, previewUrl: $previewUrl, previewTitle: $previewTitle, previewDescription: $previewDescription, previewImageUrl: $previewImageUrl, isUserChanged: $isUserChanged)';
}
