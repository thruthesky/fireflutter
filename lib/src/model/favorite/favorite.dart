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
class Favorite {
  static CollectionReference col = FirebaseFirestore.instance.collection('favorites');
  static DocumentReference doc(String id) => col.doc(id);
  final String id;
  final String? otherUid, postId, commentId;
  final String type;

  @FirebaseDateTimeConverter()
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.type,
    this.otherUid,
    this.postId,
    this.commentId,
    required this.createdAt,
  });

  factory Favorite.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Favorite.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  @override
  toString() => toJson().toString();

  /// Query
  ///
  /// Query favorites by postId, commentId, otherUid, or type
  static Query query({String? postId, String? commentId, String? otherUid, FavoriteType? type}) {
    Query query = col.where('uid', isEqualTo: myUid!);
    if (otherUid != null) {
      query = query.where('otherUid', isEqualTo: otherUid);
    } else if (postId != null) {
      query = query.where('postId', isEqualTo: postId);
    } else if (commentId != null) {
      query = query.where('commentId', isEqualTo: commentId);
    } else if (type != null) {
      query = query.where('type', isEqualTo: type.name);
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
  static Future<bool> toggle({
    String? otherUid,
    String? postId,
    String? commentId,
  }) async {
    assert(otherUid != null || postId != null || commentId != null, 'otherUid, postId, or commentId must be provided');
    final String id = "${my.uid}-${otherUid ?? postId ?? commentId}";

    final Favorite? favorite = await Favorite.get(id);

    final FavoriteType type = otherUid != null
        ? FavoriteType.user
        : postId != null
            ? FavoriteType.post
            : FavoriteType.comment;

    if (favorite == null) {
      final data = {
        'uid': my.uid,
        if (otherUid != null) 'otherUid': otherUid,
        if (postId != null) 'postId': postId,
        if (commentId != null) 'commentId': commentId,
        'type': type.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await Favorite.doc(id).set(data);
      return true;
    } else {
      await Favorite.doc(id).delete();
      return false;
    }
  }
}
