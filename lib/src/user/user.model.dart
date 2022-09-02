import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String uid = '';
  String nickname = '';
  String firstName = '';
  String photoUrl = '';

  /// TODO check if the user is admin
  bool get isAdmin => false;

  /// Use display name to display user name.
  /// Don't confuse the displayName of FirebaseAuth.
  String get displayName {
    String name = '';
    if (nickname != '') {
      name = nickname;
    } else if (firstName != '') {
      name = firstName;
    } else if (FirebaseAuth.instance.currentUser?.displayName != null) {
      name = FirebaseAuth.instance.currentUser!.displayName!;
    }
    if (name.length > 12) {
      name = name.substring(0, 10) + '...';
    }
    return name;
  }

  bool get hasDisplayName => displayName != '';

  UserModel();

  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    UserModel.fromJson(snapshot.data(), snapshot.id);
  }

  /// UserModel data set
  ///
  /// 여기에 지정되는 속성은 [this.copyWith], [this.cloneWith], [this.injectWith] 과 [this.map] 에 반드시, 꼭, 동일하게, 지정되어야 한다. README 참고
  UserModel.fromJson(dynamic data, String uid) {
    this.uid = uid;

    firstName = data['firstName'] ?? '';
  }
}
