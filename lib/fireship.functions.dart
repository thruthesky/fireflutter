import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireship/fireship.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

bool get loggedIn => FirebaseAuth.instance.currentUser != null;
bool get notLoggedIn => FirebaseAuth.instance.currentUser == null;
String? get myUid => FirebaseAuth.instance.currentUser?.uid;
bool get isAdmin => UserService.instance.user?.isAdmin ?? false;
User? get currentUser => FirebaseAuth.instance.currentUser;

void dog(String msg) {
  if (kReleaseMode) return;
  log('--> $msg', time: DateTime.now(), name: '🐶', level: 2000);
}

/// It returns one of 'web', 'android', 'fuchsia', 'ios', 'linux', 'macos', 'windows'.
String platformName() {
  if (kIsWeb) {
    return 'web';
  } else {
    return defaultTargetPlatform.name.toLowerCase();
  }
}

bool get isIos => platformName() == 'ios';

/// Returns a string of "yyyy-MM-dd" or "HH:mm:ss"
String dateTimeShort(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return DateFormat.jm().format(dt);
  } else {
    return DateFormat('yy.MM.dd').format(dt);
  }
}

/// Display an alert box.
///
/// It requires build context where [toast] does not.
///
Future error({
  required BuildContext context,
  String? title,
  required String message,
}) {
  ///
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: ErrorBox(
          title: title,
          message: message,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
