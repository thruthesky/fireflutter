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
  static CollectionReference col = FirebaseFirestore.instance.collection('favorites');
  static DocumentReference doc(String id) => col.doc(id);
  final String id;
  final String type;

  @JsonKey(includeFromJson: false, includeToJson: true)
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.type,
    dynamic createdAt,
  }) : createdAt = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();

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

  static Future<Favorite?> get(String id) async {
    try {
      final DocumentSnapshot snapshot = await doc(id).get();
      if (snapshot.exists) {
        return Favorite.fromDocumentSnapshot(snapshot);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Favorite
  ///
  /// Save as favorite if it's not in favorite list. Or remove it from favorite list.
  static Future<bool> toggle({required FavoriteType type, String? otherUid, String? postId, String? commentId}) async {
    assert(otherUid != null || postId != null || commentId != null, 'otherUid, postId, or commentId must be provided');
    final String id = "${my.uid}-${otherUid ?? postId ?? commentId}";

    final Favorite? favorite = await Favorite.get(id);

    if (favorite == null) {
      await Favorite.doc(id).set({
        'uid': my.uid,
        if (otherUid != null) 'otherUid': otherUid,
        if (postId != null) 'postId': postId,
        if (commentId != null) 'commentId': commentId,
        'type': type.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } else {
      await Favorite.doc(id).delete();
      return false;
    }
  }
}
