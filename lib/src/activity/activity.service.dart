class ActivityService {
  static ActivityService? _instance;
  static ActivityService get instance => _instance ??= ActivityService._();
  ActivityService._();

  bool userView = false;
  bool userLike = false;
  bool postCreate = false;
  bool commentCreate = false;

  init({
    bool userView = false,
    bool userLike = false,
    bool postCreate = false,
    bool commentCreate = false,
  }) {
    this.userView = userView;
    this.userLike = userLike;
    this.postCreate = postCreate;
    this.commentCreate = commentCreate;
  }
}
