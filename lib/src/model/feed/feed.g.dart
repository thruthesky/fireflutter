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
    );

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'uid': instance.uid,
      'createdAt': instance.createdAt,
    };
