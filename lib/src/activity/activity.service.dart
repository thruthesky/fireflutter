class ActivityService {
  static ActivityService? _instance;
  static ActivityService get instance => _instance ??= ActivityService._();
  ActivityService._();

  bool userView = false;
  bool userLike = false;
  bool postCreate = false;
  bool commentCreate = false;
  bool chatJoin = false;

  init({
    bool userView = false,
    bool userLike = false,
    bool postCreate = false,
    bool commentCreate = false,
    bool chatJoin = false,
  }) {
    this.userView = userView;
    this.userLike = userLike;
    this.postCreate = postCreate;
    this.commentCreate = commentCreate;
    this.chatJoin = chatJoin;
  }
}
