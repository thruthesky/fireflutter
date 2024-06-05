class Code {
  Code._();

  /// ERROR CODES
  static const String disabled = 'disabled';
  static const String notJoined = 'notJoined';
  static const String notVerified = 'not-verified';
  static const String alreadyJoined = 'already-joined';
  static const String notLoggedIn = 'notLoggedIn';
  static const String chatRoomNotVerified = 'chatRoomNotVerified';
  static const String chatRoomNotExists = 'chatRoomNotExists';
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

  // TODO review where to put this because this is under exception folder and this is not for exception things.
  // Chat Bubble Codes
  static const String readMore = 'readMore';
  static const String viewProfile = 'viewProfile';
  static const String reply = 'reply';

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
}
