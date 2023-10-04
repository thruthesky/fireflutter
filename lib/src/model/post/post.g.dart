// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      youtubeId: json['youtubeId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      urls:
          (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: const FirebaseDateTimeConverter().fromJson(json['createdAt']),
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      deleted: json['deleted'] as bool? ?? false,
      reason: json['reason'] as String?,
      noOfComments: json['noOfComments'] as int? ?? 0,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'title': instance.title,
      'content': instance.content,
      'youtubeId': instance.youtubeId,
      'uid': instance.uid,
      'hashtags': instance.hashtags,
      'urls': instance.urls,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'likes': instance.likes,
      'deleted': instance.deleted,
      'reason': instance.reason,
      'noOfComments': instance.noOfComments,
    };
