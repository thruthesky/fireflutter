import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:intl/intl.dart';

class UserModel {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String uid = '';
  String email = '';
  String nickname = '';
  String firstName = '';
  String middleName = '';
  String lastName = '';
  String gender = '';
  int birthday = 0;
  int level = 0;

  int point = 0;
  String get displayPoint => NumberFormat.currency(locale: 'ko_KR', symbol: '').format(point);

  String photoUrl = '';

  bool get ready => profileError == '';

  /// TODO return resteredAt time
  String get registeredDate => DateFormat("MMMM dd, yyyy").format(DateTime.now());

  /// TODO check if the user is admin
  bool get isAdmin => false;

  bool get notSignedIn => isAnonymous || auth.currentUser == null;

  bool get signedIn => !notSignedIn;
  bool get isAnonymous => auth.currentUser?.isAnonymous ?? false;

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

  /// return age.
  int get age {
    final String birthdayString = birthday.toString();
    if (birthdayString.length != 8) return 0;

    final today = new DateTime.now();
    final birthDate = new DateTime(
      int.tryParse(birthdayString.substring(0, 4)) ?? 0,
      int.tryParse(birthdayString.substring(4, 6)) ?? 0,
      int.tryParse(birthdayString.substring(6, 8)) ?? 0,
    );

    int age = today.year - birthDate.year;
    final m = today.month - birthDate.month;
    if (m < 0 || (m == 0 && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

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

  /// Return empty string('') if there is no error on profile.
  String get profileError {
    if (photoUrl == '') return ERROR_NO_PROFILE_PHOTO;
    if (email == '')
      return ERROR_NO_EMAIL;
    else if (EmailValidator.validate(email) == false) return ERROR_MALFORMED_EMAIL;
    if (firstName == '') return ERROR_NO_FIRST_NAME;
    if (lastName == '') return ERROR_NO_LAST_NAME;
    if (gender == '') return ERROR_NO_GENER;
    if (birthday == 0) return ERROR_NO_BIRTHDAY;
    return '';
  }
}
