import 'dart:developer';

import 'package:fireflutter/fireflutter.dart';

class FireFlutter {
  static FireFlutter get instance => _instance ?? (_instance = FireFlutter());
  static FireFlutter? _instance;

  late ErrorCallback error;
  late AlertCallback alert;
  late ConfirmCallback confirm;
  late dynamic toast;

  FireFlutter() {
    log('---> FireFlutter::constructor() ...');

    /// TODO 사용자 로그인 또는 anonymous 로그인
  }

  /// alert, confir, error, toast 등을 필요할 때, callback 으로 받아 처리한다.
  /// init() 은 반드시 호출하도록 한다. 그래서, instance 가 생성되고, 사용자 로그인을 처리한다.
  init() {
    log('---> FireFlutter::init()');
  }
}
