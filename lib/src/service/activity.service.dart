class ActivityService {
  static ActivityService? _instance;
  static ActivityService get instance {
    _instance ??= ActivityService();
    return _instance!;
  }

  ActivityService() {
    // log('ActivityService::constructor');
  }

  log(String message) {
    print('ActivityService:: $message');
  }
}
