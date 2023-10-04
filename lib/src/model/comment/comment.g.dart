// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      content: json['content'] as String? ?? '',
      uid: json['uid'] as String,
      urls:
          (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: json['createdAt'],
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      deleted: json['deleted'] as bool? ?? false,
      parentId: json['parentId'] as String?,
      sort: json['sort'] as String,
      depth: json['depth'] as int,
      deletedReason: json['deletedReason'] as String?,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'content': instance.content,
      'uid': instance.uid,
      'urls': instance.urls,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'likes': instance.likes,
      'deleted': instance.deleted,
      'deletedReason': instance.deletedReason,
      'parentId': instance.parentId,
      'sort': instance.sort,
      'depth': instance.depth,
    };
