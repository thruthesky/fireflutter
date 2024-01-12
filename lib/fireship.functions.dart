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

/// Firebase current user
User? get currentUser => FirebaseAuth.instance.currentUser;

/// UserService.instance.user
///
/// It's nullable
UserModel? get my => UserService.instance.user;

/// For more readability.
///
/// It's NOT nullable.
UserModel get iam => UserService.instance.user!;

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
      return ErrorDialog(
        title: title,
        message: message,
      );
    },
  );
}

/// Display a snackbar
///
/// When the body of the snackbar is tapped, [onTap] will be called with a callback that will hide the snackbar.
///
/// Call the function parameter passed on the callback to close the snackbar.
/// ```dart
/// toast( title: 'title',  message: 'message', onTap: (close) => close());
/// toast(  title: 'error title', message: 'error message',  error: true );
/// ```
ScaffoldFeatureController toast({
  required BuildContext context,
  String? title,
  required String message,
  Icon? icon,
  Duration duration = const Duration(seconds: 8),
  Function(Function)? onTap,
  bool? error,
  bool hideCloseButton = false,
  Color? backgroundColor,
  Color? foregroundColor,
  double runSpacing = 12,
}) {
  if (error == true) {
    backgroundColor ??= Theme.of(context).colorScheme.error;
    foregroundColor ??= Theme.of(context).colorScheme.onError;
  }
  {
    backgroundColor ??= Theme.of(context).colorScheme.primary;
    foregroundColor ??= Theme.of(context).colorScheme.onPrimary;
  }

  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: backgroundColor,
      content: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (onTap == null) return;

                onTap(() {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                });
              },
              child: Row(children: [
                if (icon != null) ...[
                  Theme(
                    data: Theme.of(context).copyWith(
                      iconTheme: IconThemeData(color: foregroundColor),
                    ),
                    child: icon,
                  ),
                  SizedBox(width: runSpacing),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title != null)
                        Text(
                          title,
                          style: TextStyle(color: foregroundColor, fontWeight: FontWeight.bold),
                        ),
                      Text(message),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          if (hideCloseButton == false)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text(
                Code.dismiss.tr,
                style: TextStyle(color: foregroundColor),
              ),
            )
        ],
      ),
    ),
  );
}

/// Confirm dialgo
///
/// It requires build context where [toast] does not.
Future<bool?> confirm({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(T.no.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(T.yes.tr),
          ),
        ],
      );
    },
  );
}

/// Prompt a dialog to get user input.
///
/// [context] is the build context.
/// [title] is the title of the dialog.
/// [subtitle] is the subtitle of the dialog.
/// [hintText] is the hintText of the input.
/// [initialValue] is the initial value of the input field.
///
/// Returns the user input.
///
/// Used in:
/// - admin.messaging.screen.dart
Future<String?> input({
  required BuildContext context,
  required String title,
  String? subtitle,
  required String hintText,
  String? initialValue,
}) {
  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      final controller = TextEditingController(text: initialValue);
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) ...[
              Text(subtitle),
              const SizedBox(height: 24),
            ],
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(T.ok.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(T.cancel.tr),
          ),
        ],
      );
    },
  );
}

String likeText(int? no) => no == null || no == 0 ? '' : ' ($no)';
