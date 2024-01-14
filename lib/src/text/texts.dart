class T {
  T._();

  /// Basic
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';

  /// Chat
  ///
  static const String chat = 'Chat';

  /// User
  static const String setting = 'Setting';
  static const String block = 'Block';
  static const String unblock = 'Unblock';
  static const String report = 'Report';
  static const String leave = 'Leave';
  static const String thisIsBlockedUser = 'You have blocked this user.';

  static const String blockConfirmTitle = 'Block this user?';
  static const String blockConfirmMessage =
      'Do you want to block this user?\nYou will not be able to contents of this user.';
  static const String unblockConfirmTitle = 'Unblock this user?';
  static const String unblockConfirmMessage = 'You will be able to contents of this user.';
  static const String notVerifiedMessage = 'You have not verified yourself.';

  /// Forum Post Comment
  static const String deletePostConfirmTitle = 'Delete this post?';
  static const String deletePostConfirmMessage =
      'Are you sure you want to delete post?\nYou will not be able to recover this post.';

  static const String deleteCommentConfirmTitle = 'Delete this comment?';
  static const String deleteCommentConfirmMessage = 'Are you sure you want to delete comment?';

  /// Block
  static const String blocked = 'Blocked';
  static const String blockedMessage = 'You have blocked this user.';

  static const String unblocked = 'Unblocked';
  static const String unblockedMessage = 'You have unblocked this user.';

  /// Report
  static const String reportInputTitle = 'Report';
  static const String reportInputMessage = 'Please enter the reason for the report.';
  static const String reportInputHint = 'Reason';
}
