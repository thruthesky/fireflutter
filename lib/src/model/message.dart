import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class Message with FirebaseHelper {
  final String id;
  final String? text;
  final String? imageUrl;
  final String senderUid;
  final Timestamp? createdAt;
  final String? fileUrl;
  final String? fileName;

  Message({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.senderUid,
    required this.createdAt,
    required this.fileUrl,
    required this.fileName,
  });

  factory Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Message.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory Message.fromMap({required Map<String, dynamic> map, required id}) {
    return Message(
      id: id,
      text: map['text'],
      imageUrl: map['imageUrl'],
      senderUid: map['senderUid'],
      createdAt: map['createdAt'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'senderUid': senderUid,
      'createdAt': createdAt,
      'fileUrl': fileUrl,
      'fileName': fileName,
    };
  }

  @override
  String toString() =>
      'Message(id: $id, text: $text,  imageUrl: $imageUrl, senderUid: $senderUid, createdAt: $createdAt, fileUrl: $fileUrl, fileName: $fileName,)';
}
