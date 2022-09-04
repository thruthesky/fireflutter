import 'dart:math';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'dart:async';

typedef BoolCallback = bool Function();
typedef FutureBoolCallback = Future<bool> Function();

/// Use this to compose an error.
/// [code] should be defined in `defines.dart` and begins with `ERROR_`.
ex(String code, String message) {
  return "$message ($code)";
}

/// splitQueryString of Uri class
///
/// The difference of [Uri.splitQueryString] is that if the string have '?',
///   then it removes the front part of it.
///   For instance, "/page?a=b&c=d", then it will parse only after '?' that is
///   "a=b&c=d".
///
/// ```dart
/// splitQueryString("/page?a=b&c=d"); // => { "a": "b", "c": "d" }
/// ```
Map<String, String> splitQueryString(String query) {
  if (query.indexOf('?') != -1) {
    query = query.substring(query.indexOf('?') + 1);
  }
  return query.split("&").fold({}, (map, element) {
    int index = element.indexOf("=");
    if (index == -1) {
      if (element != "") {
        map[element] = "";
      }
    } else if (index != 0) {
      var key = element.substring(0, index);
      var value = element.substring(index + 1);
      map[key] = value;
    }
    return map;
  });
}

/// Produce links for firestore indexes generation.
///
/// Once indexes are set, it will not produce the links any more.
/// Wait for 30 minutes after clicnk the links for the completion.
// getFirestoreIndexLinks() {
//   ReminderService.instance.settingsCol
//       .where('type', isEqualTo: 'reminder')
//       .where('link', isNotEqualTo: 'abc')
//       .get();
// }

/// Bouncer
///
/// It's very similary to 'debounce' functionality, and it's more handy to use.
/// ```dart
/// TextField(onChanged: () {
///   bounce('nickname', 500, (s) {
///     debugPrint('debounce: $s');
///   }, seed: 'nickname update');
///   bounce('3 seconds', 3000, (s) {
///     debugPrint('debounce: $s');
///   }, seed: '3 seconds delay');
/// })
/// ```
///
/// - Example of display loader while saving.
///
/// ```dart
/// setState(() => nicknameLoader = true);
/// bounce('nickname', 500, (s) async {
///   await UserService.instance.user.updateNickname(t).catchError(error);
///   setState(() => nicknameLoader = false);
/// });
/// ```
///
/// ! Do not use this anymore. Use EasyDebouncer
final Map<String, Timer> debounceTimers = {};
bounce(
  String debounceId,
  int milliseconds,
  Function(dynamic) action, {
  dynamic seed,
}) {
  debounceTimers[debounceId]?.cancel();
  debounceTimers[debounceId] = Timer(Duration(milliseconds: milliseconds), () {
    action(seed);
    debounceTimers.remove(debounceId);
  });
}

/// EO of bouncer

/// Wait until
///
/// 특정 조건이 만족 될 때까지 기다린다. 기본적으로 50 ms 간격으로 100 번을 기다린다.
/// Unit test 흘 할 때, 자주 사용되며, 특히 사용자 가입 후, `/users/<uid>` 등의 문서가 생성되기까지 기다릴 때 사용된다.
Future<int> waitUntil(bool test(),
    {final int maxIterations: 100,
    final Duration step: const Duration(milliseconds: 50)}) async {
  return waitFor(test: test, maxIterations: maxIterations, step: step);
  // int iterations = 0;
  // for (; iterations < maxIterations; iterations++) {
  //   await Future.delayed(step);
  //   if (test()) {
  //     break;
  //   }
  // }
  // if (iterations >= maxIterations) {
  //   throw TimeoutException("Condition not reached within ${iterations * step.inMilliseconds}ms");
  // }
  // return iterations;
}

/// 예제)
/// await waitFor(future: user.userDocumentExists);
Future<int> waitFor({
  BoolCallback? test,
  FutureBoolCallback? future,
  final int maxIterations: 80,
  final Duration step: const Duration(milliseconds: 100),
}) async {
  assert(test != null || future != null);
  int iterations = 0;
  for (; iterations < maxIterations; iterations++) {
    await Future.delayed(step);
    if (test != null && test()) {
      break;
    } else if (await future!()) {
      break;
    }
  }
  if (iterations >= maxIterations) {
    throw TimeoutException(
        "Condition not reached within ${iterations * step.inMilliseconds}ms");
  }
  return iterations;
}

/// EO wait until

Future<String> getAbsoluteTemporaryFilePath(String relativePath) async {
  var directory = await getTemporaryDirectory();
  return p.join(directory.path, relativePath);
}

/// Return UUID
String getRandomString() {
  const uuid = Uuid();
  return uuid.v4();
}

/// ! Attention: Alphabet `I` is missing since it is confusing with `i` and `l`.
/// ! Attention: Alphabet `O` is not included since it is confusing with `0`.
String getRandomAlphabet({int len = 1}) {
  const charset = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  var t = '';
  for (var i = 0; i < len; i++) {
    t += charset[(Random().nextInt(charset.length))];
  }
  return t;
}

/// ! Attention: Number `0` is missing since it is confusing with `O` and `o`.
String getRandomNumber({int len = 1}) {
  const charset = '123456789';
  var t = '';
  for (var i = 0; i < len; i++) {
    t += charset[(Random().nextInt(charset.length))];
  }
  return t;
}

/// add a leading 0 if the number is lessthan 10
String add0(int n) {
  // if (n < 10) return "0$n";
  return "$n";
}

/// Returns a Color from hex string.
///
/// It takes a 6 (no alpha channel) or 8 (with alpha channel) character string,
/// with or without the # prefix.
///
/// [defaultColor] is the color that will be returned if [hexColor] is malformed.
///
/// If it can't parse hex string, it returns [defaultColor].
///
/// ```dart
/// getColorFromHex('123456');
/// getColorFromHex('#123456');
/// getColorFromHex('12345678');
/// getColorFromHex('#12345678');
/// getColorFromHex(''); // error. Returns [defaultColor] color.
/// ```
Color getColorFromHex(
  String? hexColor, [
  Color defaultColor = const Color(0xFFFFFFFF),
]) {
  if (hexColor == null || hexColor == '') return defaultColor;
  hexColor = hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
    return Color(int.parse("0x$hexColor"));
  } else if (hexColor.length == 8) {
    return Color(int.parse("0x$hexColor"));
  } else {
    return defaultColor;
  }
}

bool isImageUrl(String url) {
  String t = url.toLowerCase();
  if (t.endsWith('.jpg')) return true;
  if (t.endsWith('.jpeg')) return true;
  if (t.endsWith('.png')) return true;
  if (t.endsWith('.gif')) return true;

  if (t.startsWith('http') &&
      (t.contains('.jpg') ||
          t.contains('.jpeg') ||
          t.contains('.png') ||
          t.contains('.gif'))) return true;
  return false;
}

/// Return true if the message is a URL of uploaded file in Firebase Storage.
bool isFirebaseStorageUrl(String url) {
  return url.contains('firebasestorage.googleapis.com');
}

/// Returns short date time string from Firestore Timestamp
///
/// It returns one of 'MM/DD/YYYY' or 'HH:MM AA' format.
String shortDateTime(int createdAt) {
  final date = DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
  final today = DateTime.now();
  bool re;

  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    re = true;
  } else {
    re = false;
  }
  return re
      ? DateFormat.jm().format(date).toLowerCase()
      : DateFormat.yMd().format(date);
}

/// Alias of `shortDateTime()`.
String shortDateTimeFromFirestoreTimestamp(timestamp) {
  return shortDateTime(timestamp);
}

class NotificationOptions {
  static String notifyPost = 'posts_';
  static String notifyComment = 'comments_';
  static String notifyJobs = 'jobs_';

  static String post(String topic) {
    return notifyPost + topic;
  }

  static String comment(String topic) {
    return notifyComment + topic;
  }

  static String jobs(String topic) {
    return notifyComment + topic;
  }
}

double toDouble(dynamic v) {
  if (v == null) {
    return 0;
  } else if (v is int) {
    return v.toDouble();
  } else if (v is String) {
    return double.tryParse(v) ?? 0;
  } else {
    return double.tryParse(v) ?? 0;
  }
}

/// Return an int from dynamic.
///
/// Use this to transform a string into int.
int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) {
    return v;
  } else if (v is double) {
    return v.floor();
  } else if (v is bool) {
    return v ? 1 : 0;
  } else {
    return int.tryParse(v) ?? 0;
  }
}

String tryString(dynamic v) {
  if (v == null)
    return '';
  else
    return v.toString();
}

/// Returns timestamp in seconds of client machine.
/// Note, it shoudn't be used to save timestamp on database.
int clientTimestamp() {
  return (DateTime.now().millisecondsSinceEpoch / 1000).round();
}

Future ffAlert<T>(String title, String content) {
  return showDialog<T>(
    context: FireFlutter.instance.context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(content),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(FireFlutter.instance.context).pop(),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

Future ffConfirm<T>(String title, String content) {
  return showDialog<T>(
    context: FireFlutter.instance.context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(content),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(FireFlutter.instance.context).pop(true),
          child: Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(FireFlutter.instance.context).pop(false),
          child: Text('No'),
        ),
      ],
    ),
  );
}

Future ffError<T>(dynamic content, {String title = 'Error'}) {
  return ffAlert<T>(title, content.toString());
}

/// Set data in local storage (SharedPreferences)
///
/// [value] can be one of  bool, double, int, string, List<String>
Future<bool> setLocalData(String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();
  if (value is bool) {
    return prefs.setBool(key, value);
  } else if (value is double) {
    return prefs.setDouble(key, value);
  } else if (value is int) {
    return prefs.setInt(key, value);
  } else if (value is String) {
    return prefs.setString(key, value);
  } else {
    return prefs.setStringList(key, value);
  }
}

/// Get data from SharedPreferences
///
/// Use Generic type to get the data of desired type.
Future<T?> getLocalData<T>(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.get(key) as T?;
}
