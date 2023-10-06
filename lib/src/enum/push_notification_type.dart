enum NotificationType {
  post,
  chat,
  user,
  report,
}

enum NotificationPlatform {
  allUsers,
  androidUsers,
  iosUsers,
  webUsers,
}

enum NotificationTarget {
  platform,
  users,
  tokens,
  topic,
}

enum AdminNotificationOptions {
  notifyOnNewUser,
  notifyOnNewReport,
}

enum NotificationSettingConfig {
  notifyNewCommentsUnderMyPostsAndComments,
}
