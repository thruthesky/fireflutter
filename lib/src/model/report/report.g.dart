// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      reason: json['reason'] as String,
      resolved: json['resolved'] as bool? ?? false,
      uid: json['uid'] as String?,
      otherUid: json['otherUid'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      type: json['type'] as String,
      adminNotes: json['adminNotes'] as String? ?? '',
      adminReason: json['adminReason'] as String? ?? '',
      createdAt: json['createdAt'],
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'otherUid': instance.otherUid,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'reason': instance.reason,
      'resolved': instance.resolved,
      'type': instance.type,
      'adminNotes': instance.adminNotes,
      'adminReason': instance.adminReason,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
    };
