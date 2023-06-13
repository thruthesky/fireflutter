// create a flutter model named `UserModel` with field uid, photoUrl
import 'package:firebase_database/firebase_database.dart';

class UserModel {
  UserModel({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
  });

  final String uid;
  final String photoUrl;
  final String displayName;

  factory UserModel.fromJson(Map<String, dynamic> json, String key) {
    return UserModel(
      uid: key,
      photoUrl: json['photoUrl'] ?? '',
      displayName: json['displayName'] ?? 'User has no name',
    );
  }

  factory UserModel.fromSnapshot(DataSnapshot snapshot) {
    Map<String, dynamic> json = Map<String, dynamic>.from(snapshot.value as dynamic);
    return UserModel.fromJson(json, snapshot.key!);
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'photoUrl': photoUrl,
      'displayName': displayName,
    };
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, photoUrl: $photoUrl, displayName: $displayName}';
  }
}
