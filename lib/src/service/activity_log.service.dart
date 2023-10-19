class ActivityLogService {
  static ActivityLogService? _instance;
  static ActivityLogService get instance => _instance ??= ActivityLogService._();

  ActivityLogService._();

  late List<String> adminListViewOptions;

  init({
    List<String> adminListViewOptions = const ['user', 'post', 'comment'],
  }) {
    this.adminListViewOptions = adminListViewOptions;
  }
}
