import 'package:firebase_database/firebase_database.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  final String id, postId, uid, title, content, categoryId, youtubeId;
  final List<String> urls, hashtags;

  final int createdAt;

  Feed({
    required this.id,
    required this.postId,
    required this.uid,
    required this.createdAt,
    this.title = '',
    this.content = '',
    this.categoryId = '',
    this.youtubeId = '',
    this.urls = const [],
    this.hashtags = const [],
  });

  factory Feed.fromSnapshot(DataSnapshot doc) {
    return Feed.fromJson({...Map<String, dynamic>.from(doc.value as Map), 'id': doc.key});
  }
  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
  Map<String, dynamic> toJson() => _$FeedToJson(this);
}
