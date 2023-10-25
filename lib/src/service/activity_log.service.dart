import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/functions/activity_log.functions.dart';

class ActivityLogService {
  static ActivityLogService? _instance;
  static ActivityLogService get instance => _instance ??= ActivityLogService._();

  ActivityLogService._();

  bool enableActivityLog = false;

  late List<String> adminListViewOptions;

  ActivityLogCustomize customize = ActivityLogCustomize();

  init({
    List<String> adminListViewOptions = const ['user', 'post', 'comment'],
  }) {
    enableActivityLog = true;
    this.adminListViewOptions = adminListViewOptions;
    activityLogAppStart();
    UserService.instance.userChanges.listen((user) {
      if (user == null) return;
      activityLogSignin();
    });
  }
}
