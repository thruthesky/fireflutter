// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSetting _$UserSettingFromJson(Map<String, dynamic> json) => UserSetting(
      id: json['id'] as String,
      uid: json['uid'] as String,
      action: json['action'] as String,
      categoryId: json['categoryId'] as String?,
      roomId: json['roomId'] as String?,
    );

Map<String, dynamic> _$UserSettingToJson(UserSetting instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'action': instance.action,
      'categoryId': instance.categoryId,
      'roomId': instance.roomId,
    };
