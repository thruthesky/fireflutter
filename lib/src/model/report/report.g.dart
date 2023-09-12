// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      reason: json['reason'] as String,
      uid: json['uid'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'reason': instance.reason,
      'type': instance.type,
    };
