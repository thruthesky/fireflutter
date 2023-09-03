import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

/// Message model
///
@JsonSerializable()
class Message with FirebaseHelper {
  /// [id] is the document id of the message.
  ///
  /// * This may be null since the lastMessage of chat room has no id.
  final String id;
  final String? text;
  @override
  final String uid;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  final String? url;
  final String? protocol;

  final String? previewUrl;
  final String? previewTitle;
  final String? previewDescription;
  final String? previewImageUrl;

  final bool isUserChanged;

  Message({
    this.id = "",
    required this.text,
    required this.url,
    required this.protocol,
    this.uid = "",
    dynamic createdAt,
    this.previewUrl,
    this.previewTitle,
    this.previewDescription,
    this.previewImageUrl,
    this.isUserChanged = true,
  }) : createdAt = (createdAt is Timestamp) ? createdAt.toDate() : DateTime.now();

  bool get hasUrl => url != null && url != '';
  bool get hasPreview => previewUrl != null && previewUrl != '';
  bool get isProtocol => protocol != null && protocol != '';

  factory Message.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return Message.fromJson({
      ...(documentSnapshot.data() as Map),
      ...{'id': documentSnapshot.id}
    });
  }

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  @override
  String toString() => "Message(${toJson()})";
}
