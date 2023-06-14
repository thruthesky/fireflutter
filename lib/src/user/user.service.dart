import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

class UserService {
  static String get uid => FirebaseAuth.instance.currentUser!.uid;
  static UserModel? _currentUser;
  static UserModel get currentUser => _currentUser!;

  static Future<UserModel?> listenCurrentUser() async {
    FirebaseDatabase.instance.ref('users').child(uid).onValue.listen((event) {
      _currentUser = UserModel.fromSnapshot(event.snapshot);
    });
    return null;
  }

  static DatabaseReference ref(String uid) =>
      FirebaseDatabase.instance.ref(FireFlutter.instance.options.userPath + '/$uid');

  static Future<String?> getProfilePhotoUrl(String uid) async {
    final snapshot = await ref(uid).child('photoUrl').get();
    return snapshot.value as String?;
  }

  static Future<UserModel?> getUserDocument(String uid) async {
    final snapshot = await ref(uid).get();
    return UserModel.fromSnapshot(snapshot);
  }
}
