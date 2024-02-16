import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireship/fireship.dart';

/// Firestore FirestoreUserModel Model
class FirestoreUserModel {
  String uid;
  String name;
  String email;
  String phoneNumber;
  String displayName;
  String photoUrl;
  String profileBackgroundImageUrl;
  List<String> photoUrls;
  String stateMessage;
  bool isDisabled;
  int birthYear;
  int birthMonth;
  int birthDay;
  int order;
  bool isAdmin;
  bool isVerified;
  List<String>? blocks;
  String gender;
  String idUrl;
  int idUploadedAt;
  int createdAt;
  String occupation;
  String nationality;

  /// [siDo] is composed with two region codes separated by '-'.
  /// For example, '1-11' where the first 1 is 'Seoul', and the second 11 is 'Dongdaemun-gu'.
  /// The default value of [siDo] is an empty string if the user didn't set the region code.
  String siDo;
  String siGunGu;

  Map<String, dynamic> data;
  static const String collectionName = 'users';

  /// '/users' collection
  static CollectionReference col =
      FirebaseFirestore.instance.collection(collectionName);

// user age by computing the current date  and the user given year and month and day
  String get age {
    if (birthDay == 0 || birthYear == 0 || birthYear == 0) return "";
    DateTime currentTime = DateTime.now();
    int age = currentTime.year - birthYear;
    if (currentTime.month < birthMonth ||
        (currentTime.month == birthMonth && currentTime.day < birthDay)) {
      age--;
    }
    return age.toString();
  }

  FirestoreUserModel({
    required this.data,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.displayName,
    required this.photoUrl,
    required this.profileBackgroundImageUrl,
    required this.photoUrls,
    required this.stateMessage,
    this.isDisabled = false,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    required this.createdAt,
    required this.order,
    this.isAdmin = false,
    this.isVerified = false,
    this.blocks,
    required this.gender,
    required this.idUrl,
    required this.idUploadedAt,
    required this.occupation,
    required this.nationality,
    required this.siDo,
    required this.siGunGu,
  });

  factory FirestoreUserModel.fromDocumentSnapshot(
      DocumentSnapshot documentSnapshot) {
    return FirestoreUserModel.fromJson({
      ...(documentSnapshot.data() ?? Map<String, dynamic>.from({}))
          as Map<String, dynamic>,
      'uid': documentSnapshot.id,
    });
  }

  factory FirestoreUserModel.fromJson(Map<dynamic, dynamic> json,
      {String? uid}) {
    return FirestoreUserModel(
      data: Map<String, dynamic>.from(json),
      uid: uid ?? json['uid'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      profileBackgroundImageUrl: json['profileBackgroundImageUrl'] ?? '',
      photoUrls: List<String>.from((json['photoUrls'] ?? [])),
      stateMessage: json['stateMessage'] ?? '',
      isDisabled: json['isDisabled'] ?? false,
      birthYear: json['birthYear'] ?? 0,
      birthMonth: json['birthMonth'] ?? 0,
      birthDay: json['birthDay'] ?? 0,
      gender: json['gender'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      order: json['order'] ?? 0,
      isAdmin: json['isAdmin'] ?? false,
      isVerified: json['isVerified'] ?? false,
      blocks: json[Field.blocks] == null
          ? null
          : List<String>.from(
              (json[Field.blocks] as Map<Object?, Object?>)
                  .entries
                  .map((x) => x.key),
            ),
      idUrl: json[Field.idUrl] ?? '',
      idUploadedAt: json[Field.idUploadedAt] ?? 0,
      occupation: json[Field.occupation] ?? '',
      nationality: json['nationality'] ?? '',
      siDo: json['siDo'] ?? '',
      siGunGu: json['siGunGu'] ?? '',
    );
  }
}
