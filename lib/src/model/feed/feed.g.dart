// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) => Feed(
      id: json['id'] as String,
      postId: json['postId'] as String,
      uid: json['uid'] as String,
      createdAt: json['createdAt'] as int,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      youtubeId: json['youtubeId'] as String? ?? '',
      urls:
          (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'uid': instance.uid,
      'title': instance.title,
      'content': instance.content,
      'categoryId': instance.categoryId,
      'youtubeId': instance.youtubeId,
      'urls': instance.urls,
      'hashtags': instance.hashtags,
      'createdAt': instance.createdAt,
    };
