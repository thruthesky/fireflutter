import 'package:fireflutter/fireflutter.dart';

class ActivityLogService {
  static ActivityLogService? _instance;
  static ActivityLogService get instance =>
      _instance ??= ActivityLogService._();

  ActivityLogService._();

  bool enableActivityLog = false;

  List<String> activityLogTypes = ['user', 'post', 'comment'];

  ActivityLogCustomize customize = ActivityLogCustomize();

  init({
    List<String>? customLogType,
    ActivityLogCustomize? customize,
  }) {
    enableActivityLog = true;

    activityLogAppStart();
    UserService.instance.userChanges.listen((user) {
      if (user == null) return;
      activityLogSignin();
    });

    if (customLogType != null && customLogType.isNotEmpty) {
      activityLogTypes = [...activityLogTypes, ...customLogType];
    }

    if (customize != null) {
      this.customize = customize;
    }
  }
}
