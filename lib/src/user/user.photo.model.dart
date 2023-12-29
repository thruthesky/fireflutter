import 'package:firebase_database/firebase_database.dart';

class UserPhotoModel {
  String? uid;
  String? photoUrl;
  int? updatedAt;

  UserPhotoModel({
    this.uid,
    this.photoUrl,
    this.updatedAt,
  });

  factory UserPhotoModel.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['uid'] = snapshot.key;
    return UserPhotoModel.fromJson(json);
  }

  UserPhotoModel.fromJson(Map<dynamic, dynamic> json) {
    uid = json['uid'];
    photoUrl = json['photoUrl'];
    updatedAt = json['updatedAt'];
  }
}
