import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  static CollectionReference col(String uid) => User.col.doc(uid).collection('fcm_tokens');
  static DocumentReference doc(String uid, String fcmToken) => col(uid).doc(fcmToken);

  final String id;
  final String uid;
  @JsonKey(name: 'device_type')
  final String deviceType;
  @JsonKey(name: 'fcm_token')
  final String fcmToken;

  Token({
    required this.id,
    required this.uid,
    required this.deviceType,
    required this.fcmToken,
  });

  factory Token.fromDocumentSnapshot(DocumentSnapshot snapshot) => Token.fromJson(
        {
          ...(snapshot.data() as Map),
          ...{'id': snapshot.id},
        },
      );

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);

  @override
  String toString() {
    return 'Token( ${toJson()})';
  }

  /// Get a token of a user
  ///
  static Future<Token> get({required String uid, required String token}) async {
    return Token.fromDocumentSnapshot(await doc(uid, token).get());
  }

  /// Get all tokens of the user
  static Future<List<Token>> gets({required String uid}) async {
    final snapshot = await col(uid).get();
    if (snapshot.size == 0) return [];
    return snapshot.docs.map((e) => Token.fromDocumentSnapshot(e)).toList();
  }
}
