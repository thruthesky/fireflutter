import 'package:firebase_auth/firebase_auth.dart';

/// FireFlutter Singleton
///
class FireFlutter {
  static FireFlutter? _instance;
  static FireFlutter get instance => _instance ??= FireFlutter._();

  ///
  FireFlutter._() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      //
    });
  }
}
