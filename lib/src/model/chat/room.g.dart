// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      roomId: json['roomId'] as String,
      name: json['name'] as String,
      rename: (json['rename'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      group: json['group'] as bool,
      open: json['open'] as bool,
      master: json['master'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      moderators: (json['moderators'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maximumNoOfUsers: json['maximumNoOfUsers'] as int,
      createdAt: json['createdAt'],
      lastMessage: json['lastMessage'] == null
          ? null
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'roomId': instance.roomId,
      'name': instance.name,
      'rename': instance.rename,
      'group': instance.group,
      'open': instance.open,
      'master': instance.master,
      'users': instance.users,
      'moderators': instance.moderators,
      'blockedUsers': instance.blockedUsers,
      'maximumNoOfUsers': instance.maximumNoOfUsers,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'lastMessage': instance.lastMessage,
    };
