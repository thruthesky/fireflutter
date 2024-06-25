class Code {
  Code._();

  /// ERROR CODES
  static const String disabled = 'disabled';
  static const String notJoined = 'chat-room-not-joined';
  static const String notVerified = 'not-verified';
  static const String alreadyJoined = 'already-joined';
  static const String notLoggedIn = 'notLoggedIn';
  static const String chatRoomNotVerified = 'chatRoomNotVerified';
  static const String chatRoomNotExists = 'chatRoomNotExists';
  static const String chatRoomUserGenderNotAllowed =
      'chatRoomUserGenderNotAllowed';
  static const String recentLoginRequiredForResign =
      'recentLoginRequiredForResign';

  static const String blockSelf = 'blockSelf';
  static const String profileUpdate = 'profileUpdate';
  static const String blocked = 'blocked';
  static const String block = 'block';
  static const String unblock = 'unblock';

  /// Fields and constants
  static const String uid = 'uid';

  static const String description = 'description';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String isDisabled = 'isDisabled';

  static const String userProfilePhotos = 'user-profile-photos';

  static const String roomId = 'roomId';

  static const String notMaster = 'notMaster';

  static const String chatSendMessageBlockedUser = 'chatSendMessageBlockedUser';

  /// Basic CRUD code
  static const String edit = 'edit';
  static const String view = 'view';
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String leave = 'leave';
  static const String chat = 'chat';
  static const String join = 'join';

  static const String members = 'members';
  static const String blockUser = 'blockUser';

  // Chat Bubble Codes
  static const String readMore = 'readMore';
  static const String viewProfile = 'viewProfile';
  static const String reply = 'reply';
  static const String copy = 'copy';

  static const String deleted = 'deleted';

  @Deprecated('Use Field.languageCode instead')
  static const String languageCode = 'languageCode';

  // meetup menu for admin
  static const String reminders = 'reminders';

  static const String meetupAdminSettings = 'meetupAdminSettings';

  /// Club error codes
  static const String clubAlreadyJoined = 'club-already-joined';

  /// Meetup error code
  static const String meetupAlreadyJoined = 'meetup-already-joined';
  static const String meetupNotJoined = 'meetup-not-joined';

  static const String meetupNotVerified = 'meetupNotVerified';

  static const String meetupGalleryCategoryPostFix = '-meetup-gallery';
  static const String meetupPostCategoryPostFix = '-meetup-post';

  static const String joinWithPasswordFailed = 'joinWithPasswordFailed';

  static const String category = 'category';
  static const String group = 'group';
  static const String field = 'field';
  static const String dataType = 'dataType';
  static const String all = 'all';
  static const String community = 'community';
  static const String meetup = 'meetup';
  static const String title = 'title';
  static const String content = 'content';
  static const String posts = 'posts';
  static const String comments = 'comments';
}
