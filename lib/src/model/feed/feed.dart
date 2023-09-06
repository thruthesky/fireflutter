import 'package:firebase_database/firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  final String id, postId, uid;

  final int createdAt;

  Feed({
    required this.id,
    required this.postId,
    required this.uid,
    required this.createdAt,
  });

  factory Feed.fromSnapshot(DataSnapshot doc) {
    return Feed.fromJson({...Map<String, dynamic>.from(doc.value as Map), 'id': doc.key});
  }
  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  Map<String, dynamic> toJson() => _$FeedToJson(this);
}
