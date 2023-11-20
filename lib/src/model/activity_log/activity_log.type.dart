class Log {
  static final type = ActivityLogType();
  static final user = ActivityLogUserAction();
  static final post = ActivityLogPostAction();
  static final comment = ActivityLogCommentAction();
  static final chat = ActivityLogChatAction();
}

class ActivityLogType {
  final String user = 'user';
  final String post = 'post';
  final String comment = 'comment';
  final String chat = 'chat';
}

class ActivityLogUserAction {
  final String startApp = 'startApp';
  final String signin = 'signin';
  final String signout = 'signout';
  final String resign = 'resign';
  final String create = 'create';
  final String update = 'update';
  final String like = 'like';
  final String unlike = 'unlike';
  final String follow = 'follow';
  final String unfollow = 'unfollow';
  final String viewProfile = 'viewProfile';
  final String share = 'share';
}

class ActivityLogPostAction {
  final String create = 'create';
  final String update = 'update';
  final String delete = 'delete';
  final String like = 'like';
  final String unlike = 'unlike';
  final String share = 'share';
}

class ActivityLogCommentAction {
  final String create = 'create';
  final String update = 'update';
  final String delete = 'delete';
  final String like = 'like';
  final String unlike = 'unlike';
  final String share = 'share';
}

class ActivityLogChatAction {
  final String roomOpen = 'roomOpen';
}
