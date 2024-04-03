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

  /// Fields and constants
  static const String uid = 'uid';

  static const String description = 'description';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String isDisabled = 'isDisabled';

  static const String profileViewNotification = 'profileViewNotification';

  static const String userProfilePhotos = 'user-profile-photos';

  static const String roomId = 'roomId';

  /// Basic CRUD code
  static const String edit = 'edit';
  static const String view = 'view';
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
  static const String leave = 'leave';
  static const String join = 'join';

  static const String deleted = 'deleted';

  @Deprecated('Use Field.languageCode instead')
  static const String languageCode = 'languageCode';

  // club menu for admin
  static const String reminders = 'reminders';

  /// Club error codes
  static const clubAlreadyJoined = 'club-already-joined';

  /// Meetup error code
  static const meetupAlreadyJoined = 'meetup-already-joined';
  static const meetupNotJoined = 'meetup-not-joined';
}
