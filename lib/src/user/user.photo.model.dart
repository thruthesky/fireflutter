import 'package:firebase_database/firebase_database.dart';

class UserPhoto {
  String? uid;
  String? photoUrl;
  int? updatedAt;

  UserPhoto({
    this.uid,
    this.photoUrl,
    this.updatedAt,
  });

  factory UserPhoto.fromSnapshot(DataSnapshot snapshot) {
    final json = snapshot.value as Map<dynamic, dynamic>;
    json['uid'] = snapshot.key;
    return UserPhoto.fromJson(json);
  }

  UserPhoto.fromJson(Map<dynamic, dynamic> json) {
    uid = json['uid'];
    photoUrl = json['photoUrl'];
    updatedAt = json['updatedAt'];
  }
}
