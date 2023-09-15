// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Viewer _$ViewerFromJson(Map<String, dynamic> json) => Viewer(
      seenBy: json['seenBy'] as String,
      type: json['type'] as String?,
      uid: json['uid'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      year: json['year'] as int,
      month: json['month'] as int,
      day: json['day'] as int,
    );

Map<String, dynamic> _$ViewerToJson(Viewer instance) => <String, dynamic>{
      'seenBy': instance.seenBy,
      'type': instance.type,
      'uid': instance.uid,
      'postId': instance.postId,
      'lastViewedAt': const FirebaseDateTimeConverter().toJson(instance.lastViewedAt),
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };
