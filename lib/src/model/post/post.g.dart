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
      uid: json['uid'] as String? ?? '',
      urls:
          (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: json['createdAt'],
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      deleted: json['deleted'] as bool? ?? false,
      noOfComments: json['noOfComments'] as int? ?? 0,
    )..data = json['data'] as Map<String, dynamic>?;

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'title': instance.title,
      'content': instance.content,
      'data': instance.data,
      'uid': instance.uid,
      'urls': instance.urls,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'likes': instance.likes,
      'deleted': instance.deleted,
      'noOfComments': instance.noOfComments,
    };
