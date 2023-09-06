// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
      id: json['id'] as String,
      type: json['type'] as String,
      otherUid: json['otherUid'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
    );

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
      'id': instance.id,
      'otherUid': instance.otherUid,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
    };
