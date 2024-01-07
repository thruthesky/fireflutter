import 'package:fireship/fireship.dart';

class TextService {
  static TextService? _instance;
  static TextService get instance => _instance ??= TextService._();

  /// Define your texts here. You can update this map from the app.
  Map<String, String> texts = {
    Code.profileUpdate: 'Profile Update',
    Code.notJoined: 'You have not joined this room.',
    Code.dismiss: 'Dismiss',
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
