import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String uid = '';
  String nickname = '';
  String firstName = '';
  String photoUrl = '';

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

  UserModel.fromJson() {
    nickname = '';
    firstName = '';
  }
}
