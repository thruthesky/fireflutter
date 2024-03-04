class ActivityLogService {
  static ActivityLogService? _instance;
  static ActivityLogService get instance =>
      _instance ??= ActivityLogService._();
  ActivityLogService._();

  /// [userProfileView] 는 내가 다른 사용자를 본 경우와, 다른 사용자가 나를 본 경우 두가지를 기록한다.
  bool userProfileView = false;
  bool userLike = false;
  bool postCreate = false;
  bool commentCreate = false;
  bool chatJoin = false;

  init({
    bool userProfileView = false,
    bool userLike = false,
    bool postCreate = false,
    bool commentCreate = false,
    bool chatJoin = false,
  }) {
    this.userProfileView = userProfileView;
    this.userLike = userLike;
    this.postCreate = postCreate;
    this.commentCreate = commentCreate;
    this.chatJoin = chatJoin;
  }
}
