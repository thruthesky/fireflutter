import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Login check based on Firebase current user
///
bool get loggedIn => fb.FirebaseAuth.instance.currentUser != null;
bool get notLoggedIn => fb.FirebaseAuth.instance.currentUser == null;
String? get myUid => fb.FirebaseAuth.instance.currentUser?.uid;

/// Returns true if the current user is an admin.
bool get isAdmin => AdminService.instance.isAdmin;

/// Firebase current user
fb.User? get currentUser => fb.FirebaseAuth.instance.currentUser;

/// UserService.instance.user
///
/// It's nullable
///
/// DB 에서 사용자 문서가 업데이트되면, 이 값도 자동으로 업데이트(sync)된다.
User? get my => UserService.instance.user;

/// For more readability.
///
/// It's NOT nullable.
User get iam {
  if (my == null) {
    if (UserService.instance.initialized == false) {
      throw Exception(
          'UserService is not initialized. Call UserService.instance.init()');
    }
    throw Exception(
      '[iam] UserService.instance.user is null. Developer may forget to call [UserService.instance.init()] or [UserService.instance.myDataChanges.listen()] is not complete yet.',
    );
  }
  return my!;
}

/// For more readability.
///
///
/// Example:
/// ```dart
/// Text(iHave.blocked(widget.post.uid) ? T.blockedMessage.tr : title)
/// ```
User get iHave => iam;

void dog(String msg) {
  if (kReleaseMode) return;
  log('--> $msg', time: DateTime.now(), name: '🐶', level: 2000);
}

/// 플랫폼 이름을 반환한다.
///
/// 가능하면, isIos 또는 isAndroid, kIsWeb 을 사용하도록 한다.
/// It returns one of 'web', 'android', 'fuchsia', 'ios', 'linux', 'macos', 'windows'.
String platformName() {
  if (kIsWeb) {
    return 'web';
  } else {
    return defaultTargetPlatform.name.toLowerCase();
  }
}

bool get isIos => Platform.isIOS;
bool get isAndroid => Platform.isAndroid;

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
  return FireFlutterService.instance.errorDialog
          ?.call(context: context, title: title, message: message) ??
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: title,
            message: message,
          );
        },
      );
}

Future<void> alert({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  return FireFlutterService.instance.alertDialog
          ?.call(context: context, title: title, message: message) ??
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(T.close.tr),
              ),
            ],
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
  BuildContext mayBeGlobalContext =
      FireFlutterService.instance.globalContext ?? context;

  if (error == true) {
    backgroundColor ??= Theme.of(mayBeGlobalContext).colorScheme.error;
    foregroundColor ??= Theme.of(mayBeGlobalContext).colorScheme.onError;
  }
  {
    /// if the `background` is not set it will use the toastBackgroundcolor from
    /// `FireflutterService.instance.toastBackgroundColor`and if it also not set
    ///  it will use `Theme.of(mayBeGlobalContext).colorScheme.onPrimary`
    ///
    /// if the `foregroundColor` is not set it will use the toastForegroundColor from
    /// `FireflutterService.instance.toastForegroundColor`and if it also not set
    /// it will use `Theme.of(mayBeGlobalContext).colorScheme.onPrimary`
    backgroundColor ??= FireFlutterService.instance.toastBackgroundColor ??
        Theme.of(mayBeGlobalContext).colorScheme.primary;
    foregroundColor ??= FireFlutterService.instance.toastForegroundColor ??
        Theme.of(mayBeGlobalContext).colorScheme.onPrimary;
  }

  return ScaffoldMessenger.of(mayBeGlobalContext).showSnackBar(
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
                  ScaffoldMessenger.of(mayBeGlobalContext)
                      .hideCurrentSnackBar();
                });
              },
              child: Row(children: [
                if (icon != null) ...[
                  Theme(
                    data: Theme.of(mayBeGlobalContext).copyWith(
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
                          style: TextStyle(
                              color: foregroundColor,
                              fontWeight: FontWeight.bold),
                        ),
                      Text(message, style: TextStyle(color: foregroundColor)),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          if (hideCloseButton == false)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(mayBeGlobalContext).hideCurrentSnackBar();
              },
              child: Text(
                T.dismiss.tr,
                style: TextStyle(color: foregroundColor),
              ),
            )
        ],
      ),
    ),
  );
}

ScaffoldFeatureController errorToast({
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
  return toast(
    context: context,
    title: title,
    message: message,
    icon: icon,
    duration: duration,
    onTap: onTap,
    error: true,
    hideCloseButton: hideCloseButton,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    runSpacing: runSpacing,
  );
}

/// Confirm dialgo
///
/// It requires build context.
///
/// Return true if the user taps on the 'Yes' button.
Future<bool?> confirm({
  required BuildContext context,
  required String title,
  required String message,
}) {
  return FireFlutterService.instance.confirmDialog
          ?.call(context: context, title: title, message: message) ??
      showDialog<bool?>(
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
///
/// [title] is the title of the dialog.
///
/// [subtitle] is the subtitle of the dialog.
///
/// [hintText] is the hintText of the input.
///
/// [initialValue] is the initial value of the input field.
///
/// [minLines] is the minLines of TextField
///
/// [maxLines] is the maxLines of TextField
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
  int? minLines,
  int? maxLines,
}) {
  return FireFlutterService.instance.inputDialog?.call(
          context: context,
          title: title,
          subtitle: subtitle,
          hintText: hintText,
          minLines: minLines,
          maxLines: maxLines,
          initialValue: initialValue) ??
      showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          final controller = TextEditingController(text: initialValue);
          return AlertDialog(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  minLines: minLines,
                  maxLines: maxLines,
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

/// Replaces characters in [input] that are illegal/unsafe for filenames.
///
/// You can also use a custom [replacement] if needed.
///
/// Illegal Characters on Various Operating Systems:
/// / ? < > \ : * | "
/// https://kb.acronis.com/content/39790
///
/// Unicode Control codes:
/// C0 0x00-0x1f & C1 (0x80-0x9f)
/// https://en.wikipedia.org/wiki/C0_and_C1_control_codes
///
/// Reserved filenames on Unix-based systems (".", "..")
/// Reserved filenames in Windows ("CON", "PRN", "AUX", "NUL", "COM1",
/// "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
/// "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", and
/// "LPT9") case-insesitively and with or without filename extensions.
///
/// Each results have a maximum length of 255 characters:
/// https://unix.stackexchange.com/questions/32795/what-is-the-maximum-allowed-filename-and-folder-size-with-ecryptfs
///
/// Example:
/// ```dart
/// import 'package:sanitize_filename/sanitize_filename.dart';
///
/// const unsafeUserInput = "~/.\u0000ssh/authorized_keys";
///
/// // "~.sshauthorized_keys"
/// sanitizeFilename(unsafeUserInput);
///
/// // "~-.-ssh-authorized_keys"
/// sanitizeFilename(unsafeUserInput, replacement: "-");
/// ```
String sanitizeFilename(String input, {String replacement = ''}) {
  final result = input
      // illegalRe
      .replaceAll(
        RegExp(r'[\/\?<>\\:\*\|"]'),
        replacement,
      )
      // controlRe
      .replaceAll(
        RegExp(
          r'[\x00-\x1f\x80-\x9f]',
        ),
        replacement,
      )
      // reservedRe
      .replaceFirst(
        RegExp(r'^\.+$'),
        replacement,
      )
      // windowsReservedRe
      .replaceFirst(
        RegExp(
          r'^(con|prn|aux|nul|com[0-9]|lpt[0-9])(\..*)?$',
          caseSensitive: false,
        ),
        replacement,
      )
      // windowsTrailingRe
      .replaceFirst(RegExp(r'[\. ]+$'), replacement);

  return result.length > 255 ? result.substring(0, 255) : result;
}

/// Login or register
///
/// Creates a user account if it's not existing.
///
/// [email] is the email of the user.
///
/// [password] is the password of the user.
///
/// [photoUrl] is the photo url of the user. If it's null, then it will be the default photo url.
///
/// [displayName] is the display name of the user. If it's null, then it will be the same as the email.
/// You can put empty string if you want to save it an empty stirng.
///
/// Logic:
/// Try to login with email and password.
///    -> If it's successful, return the user.
///    -> If it fails, create a new user with email and password.
///        -> If a new account is created, then update the user's display name and photo url.
///        -> And return the user.
///        -> If it's failed (to create a new user), throw an error.
///
/// ```dart
/// final email = "${randomString()}@gmail.com";
/// final randomUser = await Test.loginOrRegister(
///   TestUser(
///     displayName: email,
///     email: email,
///     photoUrl: 'https://picsum.photos/id/1/200/200'
///   ),
/// );
/// ```
///
/// Return the user object of firebase auth and whether the user is registered or not.
Future<({fb.User user, bool register})> loginOrRegister({
  required String email,
  required String password,
  String? photoUrl,
  String? displayName,
}) async {
  fb.UserCredential? cred;
  try {
    // login
    cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return (user: cred.user!, register: false);
  } catch (e) {
    // create
    cred = await fb.FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // update display name and photo url
    final user = cred.user!;
    final userModel = await User.get(user.uid);
    if (userModel == null) {
      final model = User.fromUid(user.uid);
      await model.update(
        displayName: displayName ?? email.split('@').first,
        photoUrl: photoUrl,
      );
    }

    return (user: user, register: true);
  }
}

/// Return true if the value is false, or empty.
///
bool empty(v) {
  if (v == null) return true;
  if (v is String) return v.isEmpty;
  if (v is List) return v.isEmpty;
  if (v is Map) return v.isEmpty;
  if (v == 0) return true;
  if (v == false) return true;
  return false;
}
