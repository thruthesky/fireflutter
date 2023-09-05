import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'favorite.g.dart';

enum FavoriteType {
  post,
  comment,
  user,
}

@JsonSerializable()
class Favorite with FirebaseHelper {
  static CollectionReference col = FavoriteService.instance.favoriteCol;
  final String id;
  final String type;

  Favorite({
    required this.id,
    required this.type,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  static Future<DocumentReference> create(
      {required FavoriteType type, String? otherUid, String? postId, String? commentId}) async {
    return await Favorite.col.add({
      'uid': my.uid,
      if (otherUid != null) 'otherUid': otherUid,
      if (postId != null) 'postId': postId,
      if (commentId != null) 'commentId': commentId,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
