import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<ImageSource?> chooseUploadSource(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Choose image from ...'),
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
            ElevatedButton(
              child: const Text('Close BottomSheet'),
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

/// TODO: translate
t(String code) {
  // return EasyChat.instance.t(code);
  return code;
}
