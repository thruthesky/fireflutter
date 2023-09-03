// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String? ?? "",
      text: json['text'] as String?,
      url: json['url'] as String?,
      protocol: json['protocol'] as String?,
      uid: json['uid'] as String? ?? "",
      createdAt: json['createdAt'],
      previewUrl: json['previewUrl'] as String?,
      previewTitle: json['previewTitle'] as String?,
      previewDescription: json['previewDescription'] as String?,
      previewImageUrl: json['previewImageUrl'] as String?,
      isUserChanged: json['isUserChanged'] as bool? ?? true,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'uid': instance.uid,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'url': instance.url,
      'protocol': instance.protocol,
      'previewUrl': instance.previewUrl,
      'previewTitle': instance.previewTitle,
      'previewDescription': instance.previewDescription,
      'previewImageUrl': instance.previewImageUrl,
      'isUserChanged': instance.isUserChanged,
    };
