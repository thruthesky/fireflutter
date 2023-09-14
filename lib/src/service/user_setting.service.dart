import 'package:fireflutter/fireflutter.dart';

class UserSettingService with FirebaseHelper {
  static UserSettingService? _instance;
  static UserSettingService get instance => _instance ?? UserSettingService._();

  UserSettingService._();

  /// Get a setting
}
