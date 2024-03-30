import 'package:flutter/material.dart';

class FireFlutterService {
  static FireFlutterService? _instance;
  static FireFlutterService get instance =>
      _instance ??= FireFlutterService._();

  FireFlutterService._();

  /// Global BuildContext
  ///
  /// 상위 앱의 global build context 를 사용하게 할 때 사용한다.
  /// 즉, [globalContext] 를 지정하면, 상위 앱의 global build context 를 사용하는데, 이렇게하면,
  /// FireFlutter 에서 사용하는 snackbar 나 기타 UI 의 context 들이 앱의 global context 와
  /// 일치하여,
  BuildContext Function()? _globalContext;
  BuildContext? get globalContext => _globalContext?.call();

  init({
    BuildContext Function()? globalContext,
  }) {
    _globalContext = globalContext;
  }
}
