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
}

enum AdminNotificationOptions {
  notifyOnNewUser,
  notifyOnNewReport,
}
