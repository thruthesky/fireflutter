class NotificationType {
  static const String post = 'post';
  static const String chat = 'chat';
  static const String user = 'user';
  static const String report = 'report';
}

class NotificationPlatform {
  static const String allUsers = 'allUsers';
  static const String androidUsers = 'androidUsers';
  static const String iosUsers = 'iosUsers';
  static const String webUsers = 'webUsers';
}

class NotificationTarget {
  static const String platform = 'platform';
  static const String users = 'users';
  static const String tokens = 'tokens';
  static const String topic = 'topic';
}

class AdminNotificationOptions {
  static const String notifyOnNewUser = 'notifyOnNewUser';
  static const String notifyOnNewReport = 'notifyOnNewReport';
}

class NotificationSettingConfig {
  static const String disableNotifyNewCommentsUnderMyPostsAndComments =
      'disableNotifyNewCommentsUnderMyPostsAndComments';
  static const String disableNotifyOnProfileVisited = 'disableNotifyOnProfileVisited';
  static const String disableNotifyOnProfileLiked = 'disableNotifyOnProfileLiked';
  static const String disableNotifyOnPostLiked = 'disableNotifyOnPostLiked';
  static const String disableNotifyOnCommentLiked = 'disableNotifyOnCommentLiked';
}
