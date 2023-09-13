import 'dart:math';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

/// Shows a [SnackBar] at the bottom of the screen.
Future<void> showSnackBar(BuildContext? context, String message) async {
  context ??= FireFlutterService.instance.context;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}

Future<ImageSource?> chooseUploadSource(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Text(tr.upload.chooseFrom),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Photo Gallery'),
              onTap: () async {
                Navigator.pop(context, ImageSource.gallery);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    },
  );
  return source;
}

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

/// Alias of [ChatService.instance.getOtherUserUid]
///
/// Returns the other user's uid from a list of users.
String otherUserUid(List<String> users) {
  return ChatService.instance.getOtherUserUid(users);
}

/// Returns the indent value for the given [no].
///
/// Use this to display the indent for comment reply.
/// The indent(depth) start with 1.
double indent(int? no) {
  if (no == null) return 0;
  if (no == 0 || no == 1) {
    return 0;
  } else if (no == 2) {
    return 32;
  } else if (no == 3) {
    return 64;
  } else if (no == 4) {
    return 80;
  } else if (no == 5) {
    return 96;
  } else if (no == 6) {
    return 106;
  } else {
    return 112;
  }
}

/// It returns one of 'web', 'android', 'fuchsia', 'ios', 'linux', 'macos', 'windows'.
String platformName() {
  if (kIsWeb) {
    return 'web';
  } else {
    return defaultTargetPlatform.name.toLowerCase();
  }
}

void warningSnackbar(BuildContext? context, String message) async {
  context ??= FireFlutterService.instance.context;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

/// Display a snackbar
///
/// When the body of the snackbar is tapped, [onTap] will be called with a callback that will hide the snackbar.
///
/// Call the function parameter passed on the callback to close the snackbar.
/// ```dart
/// toast( title: 'title',  message: 'message', onTap: (close) => close());
/// ```
ScaffoldFeatureController toast({
  required String title,
  required String message,
  Widget? icon,
  Duration duration = const Duration(seconds: 8),
  Function(Function)? onTap,
}) {
  final context = FireFlutterService.instance.context;
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
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
                if (icon != null) ...[icon, const SizedBox(width: 8)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title),
                      Text(message),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Text(tr.toast.dismiss))
        ],
      ),
    ),
  );
}

ScaffoldFeatureController loginFirstToast({
  Widget? icon,
  Duration duration = const Duration(seconds: 8),
  Function(Function)? onTap,
}) {
  return toast(
    title: tr.user.loginFirstTitle,
    message: tr.user.loginFirstMessage,
    icon: icon,
    duration: duration,
    onTap: onTap,
  );
}

/// Confirm dialgo
///
/// It requires build context where [toast] does not.
Future<bool?> confirm(
    {required BuildContext context,
    required String title,
    required String message}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.confirm.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.confirm.yes),
          ),
        ],
      );
    },
  );
}

/// Display an alert box.
///
/// It requires build context where [toast] does not.
Future alert(
    {required BuildContext context,
    required String title,
    required String message}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.alert.ok),
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
/// [message] is the message of the dialog.
/// [initialValue] is the initial value of the input field.
Future<String?> prompt(
    {required BuildContext context,
    required String title,
    required String message,
    String? initialValue}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: message),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(tr.prompt.ok),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.prompt.cancel),
          ),
        ],
      );
    },
  );
}

/// randomString that returns a random string of length [length].
String randomString([length = 12]) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random(DateTime.now().millisecondsSinceEpoch);
  final buf = StringBuffer();
  for (var x = 0; x < length; x++) {
    buf.write(chars[rnd.nextInt(chars.length)]);
  }
  return buf.toString();
}

/// Return a string of date/time agao
String dateTimeAgo(DateTime dateTime) {
  final Duration diff = DateTime.now().difference(dateTime);
  if (diff.inDays >= 31) {
    return dateTime.toIso8601String();
  } else if (diff.inDays >= 1) {
    return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago';
  } else if (diff.inSeconds >= 1) {
    return '${diff.inSeconds} ${diff.inSeconds == 1 ? "second" : "seconds"} ago';
  } else {
    return 'just now';
  }
}

/// Returns a string of "yyyy-MM-dd" or "HH:mm:ss"
String dateTimeShort(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return DateFormat.jm().format(dt);
  } else {
    return DateFormat('yy.MM.dd').format(dt);
  }
}

/// Converts fully qualified YouTube Url to video id.
///
/// If videoId is passed as url then no conversion is done.
///
/// Note, this code is copied from [youtube_player_flutter] package.
String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
  if (!url.contains("http") && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();

  for (var exp in [
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:music\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    Match? match = exp.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }

  return null;
}
