// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLog _$ActivityLogFromJson(Map<String, dynamic> json) => ActivityLog(
      id: json['id'] as String,
      uid: json['uid'] as String,
      otherUid: json['otherUid'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      roomId: json['roomId'] as String?,
      type: json['type'] as String,
      action: json['action'] as String,
      createdAt: const FirebaseDateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ActivityLogToJson(ActivityLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'otherUid': instance.otherUid,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'roomId': instance.roomId,
      'type': instance.type,
      'action': instance.action,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
    };
