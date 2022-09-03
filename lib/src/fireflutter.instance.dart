import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:fireflutter/fireflutter.dart';

class FireFlutter {
  static FireFlutter get instance => _instance ?? (_instance = FireFlutter());
  static FireFlutter? _instance;

  late ErrorCallback error;
  late AlertCallback alert;
  late ConfirmCallback confirm;
  late dynamic toast;

  Firebase.FirebaseAuth auth = Firebase.FirebaseAuth.instance;

  /// 생성자는 한번만 호출된다.
  FireFlutter() {
    log('---> FireFlutter::constructor()');

    /// 사용자 로그인
    ///
    /// * 사용자 정보를 미리 읽지 않는다. README 참고.
    auth.authStateChanges().listen((firebaseUser) async {
      ///
      if (firebaseUser == null) {
        log('---> Not signed in. signInAnonymously()');
        await auth.signInAnonymously();
      } else {
        if (firebaseUser.isAnonymous) {
          log('---> The user is anonymous');
        } else {
          log('---> The user is not anonymous. email: ${firebaseUser.email}, phone: ${firebaseUser.phoneNumber}');
        }
      }
    });
  }

  /// alert, confir, error, toast 등을 필요할 때, callback 으로 받아 처리한다.
  /// init() 은 반드시 호출하도록 한다. 그래서, instance 가 생성되고, 사용자 로그인을 처리한다.
  /// 이 함수는 여러번 호출될 수 있고, 호출 할 때 마다 다른 값으로 초기화 할 수 있다.
  init() {
    log('---> FireFlutter::init()');
  }
}
