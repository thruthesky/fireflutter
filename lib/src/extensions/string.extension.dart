import 'package:fireship/fireship.dart';

extension FireFlutterStringExtension on String {
  int? tryInt() {
    return int.tryParse(this);
  }

  double? tryDouble() {
    return double.parse(this);
  }

  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Return value if the current string is empty.
  ///
  /// example
  /// ```dart
  /// ''.ifEmpty('This is empty!') // result: 'This is empty!'
  /// String? uid; uid?.ifEmpty('UID is empty!') // result: null
  ///
  /// ```
  String ifEmpty(String value) => isEmpty ? value : this;

  String upTo(int len) => length <= len ? this : substring(0, len);

  /// Replace all the string of the map.
  String replace(Map<String, String> map) {
    String s = this;
    map.forEach((key, value) {
      s = s.replaceAll(key, value);
    });
    return s;
  }

  /// Return true if the string contains the url.
  bool get hasUrl => contains('http://') || contains('https://');

  /// 해당 문자열이 빈 문자열이면, 익명 프로필 사진 URL 을 반환한다.
  String get orAnonymousUrl => isEmpty ? anonymousUrl : this;

  /// 해당 문자열이 빈 문자열이면, 검은색 사진 URL 을 반환한다.
  String get orBlackUrl => isEmpty ? blackUrl : this;

  /// 해당 문자열이 빈 문자열이면, 흰색 사진 URL 을 반환한다.
  String get orWhiteUrl => isEmpty ? whiteUrl : this;
}
