class UserSettingService {
  static UserSettingService? _instance;
  static UserSettingService get instance => _instance ?? UserSettingService._();

  UserSettingService._();

  /// Get a setting
}
