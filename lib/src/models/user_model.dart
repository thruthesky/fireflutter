import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String photoUrl;
  final bool hasPhotoUrl;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.photoUrl,
  }) : hasPhotoUrl = photoUrl.isNotEmpty;

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return UserModel.fromMap(map: documentSnapshot.data() as Map<String, dynamic>, id: documentSnapshot.id);
  }

  factory UserModel.fromMap({required Map<String, dynamic> map, required String id}) {
    final displayName = map['displayName'] ?? '';
    return UserModel(
      uid: id,
      displayName: displayName == '' ? id.toUpperCase().substring(0, 2) : displayName,
      photoUrl: (map['photoUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() => 'UserModel(id: $uid, displayName: $displayName)';
}
