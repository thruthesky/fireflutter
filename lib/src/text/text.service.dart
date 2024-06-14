import 'package:fireflutter/fireflutter.dart';

/// Text Service
///
/// Example:
/// ```dart
/// Text(T.version.args({'version': '1.0.0'})),
/// Text(T.yes.tr),
///
///
/// TextService.instance.init(languageCode: 'ja');
/// Text({'ja': 'Yo....'}.tr),
/// Text({'ja': 'Yo: #no'}.args({'no': '123'})),
/// ```
class TextService {
  static TextService? _instance;
  static TextService get instance => _instance ??= TextService._();

  init({
    String? languageCode,
  }) {
    // Load texts from the server.
    if (languageCode != null) {
      this.languageCode = languageCode;
    }
  }

  String languageCode = 'en';

  /// Define your texts here. You can update this map from the app.
  Map<String, String> texts = {
    // T.ok: 'OK',
    // T.no: 'No',
    // T.yes: 'Yes',
    // T.error: 'Error',
    // T.save: 'Save',
    // T.saved: 'Saved.',
    // T.name: 'Name',
    // T.profileUpdate: 'Profile Update',
    T.profilePhoto: 'Profile Photo',
    T.backgroundImage: 'Background Image',
    T.takePhotoClosely: 'Take a photo closely',
    Code.notJoined: 'You have not joined this room.',
    T.dismiss: 'Dismiss',
    Code.notVerified: 'Not verified',
    // T.notVerifiedMessage:
    //     'You have not verified your email address. Please verify your email address.',
    T.recentLoginRequiredForResign:
        'Please sign out and sign in again to resign. Recent login required for resign.',
    // T.nameInputDescription: "Please enter your name.",
    // T.stateMessage: 'State Message',
    T.stateMessageDescription: 'Please enter your state message.',
    T.birthdateLabel: 'Birthdate',
    T.birthdateSelectDescription: 'Please select your birthdate.',
    T.birthdateTapToSelect: 'Tap to select',
    T.birthdate: '#birthMonth/#birthDay/#birthYear',
    // T.email: 'Email',
    // T.password: 'Password',
    // T.login: 'Login',
    // T.next: 'Next',
    // T.prev: 'Prev',
    // T.back: 'Back',
    T.selectBirthDate: 'Select Birth',
  };

  TextService._() {
    dog('--> TextService._()');
  }
  text(String key) {
    return texts[key] ?? key;
  }

  mintl(Json map, [Map<String, String>? args]) {
    if (args == null) {
      return (map[languageCode] ?? map['en']).toString();
    } else {
      String s = (map[languageCode] ?? map['en']).toString();

      args.forEach((key, value) {
        s = s.replaceAll('#$key', value);
      });
      return s;
    }
  }
}

extension TranslationServiceExtension on String {
  /// Translate the string.
  String get tr => TextService.instance.text(this);
}

extension TranslationServiceExtensionMap on Json {
  /// Translate the string from the Mintl.
  ///
  /// Example:
  /// ```dart
  /// T.version.tr.replace({'#version': '1.0.0'})
  /// ```
  String get tr => TextService.instance.mintl(this);
  String args(Map<String, String> args) =>
      TextService.instance.mintl(this, args);
}
