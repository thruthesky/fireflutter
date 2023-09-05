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
  static DocumentReference doc(String id) => col.doc(id);
  final String id;
  final String type;

  Favorite({
    required this.id,
    required this.type,
  });

  factory Favorite.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Favorite.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  @override
  toString() => toJson().toString();

  static Query query({String? postId}) {
    Query query = col.where('uid', isEqualTo: UserService.instance.uid);
    if (postId != null) {
      query = query.where('postId', isEqualTo: postId);
    }
    query = query.orderBy('createdAt', descending: true);
    return query;
  }

  static Future<void> create({required FavoriteType type, String? otherUid, String? postId, String? commentId}) async {
    assert(otherUid != null || postId != null || commentId != null, 'otherUid, postId, or commentId must be provided');
    return await Favorite.col.doc("${my.uid}-${otherUid ?? postId ?? commentId}").set({
      'uid': my.uid,
      if (otherUid != null) 'otherUid': otherUid,
      if (postId != null) 'postId': postId,
      if (commentId != null) 'commentId': commentId,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
