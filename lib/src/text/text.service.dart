import 'package:fireship/fireship.dart';

class TextService {
  static TextService? _instance;
  static TextService get instance => _instance ??= TextService._();

  /// Define your texts here. You can update this map from the app.
  Map<String, String> texts = {
    T.ok: 'OK',
    T.no: 'No',
    T.yes: 'Yes',
    T.error: 'Error',
    T.save: 'Save',
    T.saved: 'Saved.',
    T.name: 'Name',
    T.profileUpdate: 'Profile Update',
    T.profilePhoto: 'Profile Photo',
    T.backgroundImage: 'Background Image',
    T.takePhotoClosely: 'Take a photo closely',
    Code.notJoined: 'You have not joined this room.',
    T.dismiss: 'Dismiss',
    Code.notVerified: 'Not verified',
    T.notVerifiedMessage:
        'You have not verified your email address. Please verify your email address.',
    T.recentLoginRequiredForResign:
        'Please sign out and sign in again to resign. Recent login required for resign.',
    T.nameInputDescription: "Please enter your name.",
    T.stateMessage: 'State Message',
    T.stateMessageDescription: 'Please enter your state message.',
    T.birthdateLabel: 'Birthdate',
    T.birthdateSelectDescription: 'Please select your birthdate.',
    T.birthdateTapToSelect: 'Tap to select',
    T.birthdate: '#birthMonth/#birthDay/#birthYear',
  };

  TextService._() {
    dog('--> TextService._()');
  }
  text(String key) {
    return texts[key] ?? key;
  }
}

extension TranslationServiceExtension on String {
  String get tr => TextService.instance.text(this);
}
