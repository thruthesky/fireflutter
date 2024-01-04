import 'package:fireship/fireship.dart';

class TranslationService {
  static TranslationService? _instance;
  static TranslationService get instance =>
      _instance ??= TranslationService._();

  /// Define your texts here. You can update this map from the app.
  Map<String, String> texts = {
    Code.notJoined: 'You have not joined this room.',
  };

  TranslationService._() {
    dog('--> TranslationService._()');
  }
  text(String key) {
    return texts[key] ?? ('@{$key}');
  }
}

extension TranslationServiceExtension on String {
  String get tr => TranslationService.instance.text(this);
}
