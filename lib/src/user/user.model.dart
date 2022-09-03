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
  String get displayPoint =>
      NumberFormat.currency(locale: 'ko_KR', symbol: '').format(point);

  String photoUrl = '';

  /// 주의: 문서가 존재하는지 하지 않는지는 확인을 위해서는 반드시, fromSnapshot() 통해서 모델링을 해야 한다.
  /// 만약, fromData() 를 통해서 속성 설정을 하면, [exists] 는 알수 없는 상태인 null 이 된다.
  /// 주의: exists 가 null 또는 false 라도, uid 는 설정된다.
  bool? exists;
  bool get ready => profileError == '';

  bool get isAdmin => false;

  bool get notSignedIn =>
      isAnonymous || FirebaseAuth.instance.currentUser == null;
  bool get signedOut => notSignedIn;

  bool get signedIn => !notSignedIn;
  bool get isAnonymous =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  /// TODO return resteredAt time
  String get registeredDate =>
      DateFormat("MMMM dd, yyyy").format(DateTime.now());

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

  ///
  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    exists = snapshot.exists;
    UserModel.fromData(snapshot.data(), snapshot.id);
  }

  /// UserModel data set
  ///
  /// 여기에 지정되는 속성은 [this.copyWith], [this.cloneWith], [this.injectWith] 과 [this.map] 에 반드시, 꼭, 동일하게, 지정되어야 한다.
  /// README 참고
  UserModel.fromData(dynamic data, String uid) {
    this.uid = uid;
    if (data == null) return;
    firstName = data['firstName'] ?? '';
    lastName = data['lastName'] ?? '';
    middleName = data['middleName'] ?? '';
  }

  /// Return empty string('') if there is no error on profile.
  String get profileError {
    if (photoUrl == '') return ERROR_NO_PROFILE_PHOTO;
    if (email == '')
      return ERROR_NO_EMAIL;
    else if (EmailValidator.validate(email) == false)
      return ERROR_MALFORMED_EMAIL;
    if (firstName == '') return ERROR_NO_FIRST_NAME;
    if (lastName == '') return ERROR_NO_LAST_NAME;
    if (gender == '') return ERROR_NO_GENER;
    if (birthday == 0) return ERROR_NO_BIRTHDAY;
    return '';
  }
}
