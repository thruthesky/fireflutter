// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      action: json['action'] as String,
      type: json['type'] as String,
      uid: json['uid'] as String,
      name: json['name'] as String,
      createdAt: const FirebaseDateTimeConverter().fromJson(json['createdAt']),
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      roomId: json['roomId'] as String?,
      title: json['title'] as String?,
      otherUid: json['otherUid'] as String?,
      otherDisplayName: json['otherDisplayName'] as String?,
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'action': instance.action,
      'type': instance.type,
      'uid': instance.uid,
      'name': instance.name,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'roomId': instance.roomId,
      'title': instance.title,
      'otherUid': instance.otherUid,
      'otherDisplayName': instance.otherDisplayName,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
    };
