// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
      id: json['id'] as String,
      reporters: (json['reporters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      otherUid: json['otherUid'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      type: json['type'] as String,
      reportedBy: (json['reportedBy'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      createdAt: const FirebaseDateTimeConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'reporters': instance.reporters,
      'otherUid': instance.otherUid,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'type': instance.type,
      'reportedBy': instance.reportedBy,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
    };
