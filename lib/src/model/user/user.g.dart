// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      uid: json['uid'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      displayName: json['displayName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      middleName: json['middleName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      hasPhotoUrl: json['hasPhotoUrl'] as bool? ?? false,
      idVerifiedCode: json['idVerifiedCode'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? false,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      state: json['state'] as String? ?? '',
      stateImageUrl: json['stateImageUrl'] as String? ?? '',
      birthYear: json['birthYear'] as int? ?? 0,
      birthMonth: json['birthMonth'] as int? ?? 0,
      birthDay: json['birthDay'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      isComplete: json['isComplete'] as bool? ?? false,
      exists: json['exists'] as bool? ?? true,
      noOfPosts: json['noOfPosts'] as int? ?? 0,
      noOfComments: json['noOfComments'] as int? ?? 0,
      followers: (json['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followings: (json['followings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cached: json['cached'] as bool? ?? false,
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uid': instance.uid,
      'isAdmin': instance.isAdmin,
      'displayName': instance.displayName,
      'name': instance.name,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'photoUrl': instance.photoUrl,
      'idVerifiedCode': instance.idVerifiedCode,
      'isVerified': instance.isVerified,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'state': instance.state,
      'stateImageUrl': instance.stateImageUrl,
      'birthYear': instance.birthYear,
      'birthMonth': instance.birthMonth,
      'birthDay': instance.birthDay,
      'noOfPosts': instance.noOfPosts,
      'noOfComments': instance.noOfComments,
      'type': instance.type,
      'hasPhotoUrl': instance.hasPhotoUrl,
      'createdAt': const FirebaseDateTimeConverter().toJson(instance.createdAt),
      'isComplete': instance.isComplete,
      'followers': instance.followers,
      'followings': instance.followings,
      'exists': instance.exists,
      'cached': instance.cached,
      'likes': instance.likes,
    };
