import 'package:fireflutter/fireflutter.dart';
import 'package:intl/intl.dart';

extension FireFlutterStringExtension on String {
  /// 문자를 정수로 변환
  ///
  /// 만약 변환할 수 없다면 0을 리턴.
  int tryInt() {
    return int.tryParse(this) ?? 0;
  }

  double? tryDouble() {
    return double.parse(this);
  }

  bool get isEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Return value if the current string is empty.
  ///
  /// example
  /// ```dart
  /// ''.ifEmpty('This is empty!') // result: 'This is empty!'
  /// String? uid; uid?.ifEmpty('UID is empty!') // result: null
  ///
  /// ```
  String ifEmpty(String value) => isEmpty ? value : this;

  /// If the string is empty, return the value.
  ///
  /// example
  /// ```dart
  /// String gender = user.gender.or(null);
  /// ```
  String or(String value) => isEmpty ? value : this;

  /// If the string is empty, return tnull
  dynamic get orNull => isEmpty ? null : this;

  String upTo(int len) => length <= len ? this : substring(0, len);

  /// Cut the string
  ///
  /// ```dart
  /// Text( comment.content.cut(56) );
  /// ```
  String cut(int length, {String suffix = '...'}) {
    String temp = this;
    temp = temp.trim();
    temp = temp.replaceAll('\n', ' ');
    temp = temp.replaceAll('\r', ' ');
    temp = temp.replaceAll('\t', ' ');
    return temp.length > length ? '${temp.substring(0, length)}$suffix' : temp;
  }

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

  /// 각종 특수 문자를 없앤다.
  String get sanitize => trim().replaceAll(RegExp(r'[\r\n\t]'), " ");

  String orBlocked(String uid, String message) {
    return iHave.blocked(uid) ? message : this;
  }

  /// 문자열을 DateTime 으로 변경한다. 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, null 을 리턴하지 않고
  /// 현재 시간을 리턴한다.
  ///
  /// 예) '2021-01-01' -> 2021-01-01 00:00:00.000
  DateTime get dateTime {
    try {
      return DateTime.parse(this);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// 문자열을 DateTime 으로 변경한 다음, YYYY-MM-DD 형태로 리턴한다.
  /// 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.
  ///
  /// 예) 20210101 -> 2021-01-01
  // ignore: non_constant_identifier_names
  String get Ymd {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 문자열을 DateTime 으로 변경한 다음, YY-MM-DD 형태로 리턴한다. 앞에 년도가 두 자리 수 이다.
  /// 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.
  String get ymd {
    return '${dateTime.year.toString().substring(2)}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// 문자열을 DateTime 으로 변경한 다음, YYYY-MM-DD HH:MM:SS 형태로 리턴한다.
  /// 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.
  // ignore: non_constant_identifier_names
  String get YmdHms {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // ignore: non_constant_identifier_names
  String get YmdHm {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 문자열을 DateTime 으로 변경한 다음, MM-DD 형태로 리턴한다.
  /// 만약, 문자열의 값이 시간 형식이 아니라서 파싱이 안되면, 현재 시간을 기준으로 날짜 값을 리턴한다.
  /// 예) 2021-01-01 -> 01-01
  String get md {
    return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Returns in the format of "HH:mm:ss" from dateTime
  String get his {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 문자열을 DateTime 으로 변경한 다음,
  /// - 오늘 날짜이면, HH:MM AM 로 리턴하고
  /// - 오늘 날짜가 아니면, YYYY-MM-DD 형태로 리턴한다.
  String get shortDateTime {
    final dt = dateTime;
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat.jm().format(dt);
    } else {
      return DateFormat('yy.MM.dd').format(dt);
    }
  }
}

/// 문자열이 null 이거나 빈 문자열인지 확인하는 확장 함수
///
/// String? 을 extends 에서 null 인지 아닌지를 검사한다.
extension FireFlutterNullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
