// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      id: json['id'] as String,
      uid: json['uid'] as String,
      deviceType: json['device_type'] as String,
      fcmToken: json['fcm_token'] as String,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'id': instance.id,
      'uid': instance.uid,
      'device_type': instance.deviceType,
      'fcm_token': instance.fcmToken,
    };
