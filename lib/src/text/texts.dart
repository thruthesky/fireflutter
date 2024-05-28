/// Multi language internalization
typedef Mintl = Map<String, String>;

class T {
  T._();

  /// New translations
  static Mintl version = {
    'en': 'Ver: #version',
    'ko': '버전: #version',
  };

  static Mintl yes = {
    'en': 'Yes',
    'ko': '예',
  };

  static Mintl no = {
    'en': 'No',
    'ko': '아니요',
  };

  static Mintl ok = {
    'en': 'OK',
    'ko': '확인',
  };

  static Mintl error = {
    'en': 'Error',
    'ko': '오류',
  };

  static Mintl save = {
    'en': 'Save',
    'ko': '저장',
  };

  static Mintl saved = {
    'en': 'Saved.',
    'ko': '저장되었습니다.',
  };

  static Mintl name = {
    'en': 'Name',
    'ko': '이름',
  };

  static Mintl cancel = {
    'en': 'Cancel',
    'ko': '취소',
  };

  static Mintl close = {
    'en': 'Close',
    'ko': '닫기',
  };

  /// Basic
  // static const String yes = 'Yes';
  // static const String no = 'No';
  // static const String ok = 'OK';
  // static const String save = 'Save';
  // static const String cancel = 'Cancel';
  // static const String close = 'Close';
  static const String inputName = 'Please enter your name.';
  static const String nameInputDescription = 'NameInputDescription';

  static const String email = 'Email';
  static const String inputEmail = 'Please enter your email.';
  static const String password = 'Password';
  static const String inputPassword = 'Please enter your password.';
  static const String login = 'Login';
  static const String next = 'Next';
  static const String prev = 'Prev';
  static const String back = 'Back';
  static const String like = 'Like';
  static const String likes = 'Likes';
  static const String bookmark = 'Favorite';
  static const String bookmarkMessage = 'Favorite sucess';
  static const String unbookmark = 'Unfavorite';
  static const String unbookmarkMessage = 'Unfavorite success';
  static const String thereAreNoBookmarksInTheList =
      'There are no bookmarks in the list.';

  static const String share = 'Share';

  static const String inputTitle = 'Input title';
  static const String inputContent = 'Input content';

  /// Label, texts, buttons,
  static const String dismiss = 'dismiss';

  /// Chat
  ///
  static const String chat = 'Chat';
  static const String chatRoomNoMessageYet = 'There is no message, yet.';
  static const String thereIsNoChatRoomInChatRoomListView =
      'There is no chat room.';

  static const String chatMessageDelete = 'Delete';
  static const String chatMessageDeleted = 'This message is deleted.';

  static const String chatBlockedUserList = 'Blocked users';

  static const String chatEmptyBlockedUserList = 'No blocked users.';
  static const String chatMessageListPermissionDenied = 'Permission denied.';

  static const String chatSendMessageBlockedUser = 'You are blocked.';

  static const String chatMessageListViewBlockedUser =
      'You are blocked from this chat.';

  /// User
  static const String setting = 'Setting';
  static const String block = 'Block';
  static const String unblock = 'Unblock';
  static const String report = 'Report';
  static const String leave = 'Leave';
  static const String stateMessage = 'State Message';
  static const String stateMessageInProfileUpdate = 'STATE MESSAGE';
  static const String hintInputStateMessage = 'Please input your state message';
  static const String stateMessageDescription = 'State Message Description';

  static const String blockConfirmTitle = 'Block this user?';
  static const String blockConfirmMessage =
      'Do you want to block this user?\nYou will not be able to contents of this user.';
  static const String unblockConfirmTitle = 'Unblock this user?';
  static const String unblockConfirmMessage =
      'If you unblock this user, you will be able to see the contents of this user.';
  static const String notVerifiedMessage = 'You have not verified yourself.';
  static const String writeYourMessage = 'Write your message';
  static const String visitedYourProfileTitle = 'Your profile was visited.';
  static const String visitedYourProfileBody = '#name visited your profile';
  // chat input box hint text -> please enter a message
  static const String pleaseEnterMessage = 'Please enter message.';
  static const String cannotBlockYourself = 'You cannot block yourself.';

  /// User and Profile
  static const String recentLoginRequiredForResign =
      'recentLoginRequiredForResign';

  static const String backgroundImage = 'Background Image';
  static const String profileUpdate = 'Profile Update';
  static const String profilePhoto = 'Profile Photo';
  static const String takePhotoClosely = 'Take a photo closely';

  static const String birthdateLabel = 'Birthdate';
  static const String birthdateSelectDescription = 'birthdateSelectDescription';
  static const String birthdateTapToSelect = 'Tap to select';
  static const String birthdate = 'birthdate';
  static const String selectBirthDate = 'Select Birth';

  static const String yearInBirthdatePicker = 'Year';
  static const String monthInBirthdatePicker = 'Month';
  static const String dayInBirthdatePicker = 'Day';
  static const String descriptionInBirthdatePicker =
      'Please select your birthdate.';

  // profile update labels and error messages
  static const String gender = 'Gender';
  static const String genderInProfileUpdate = 'GENDER';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String nationality = 'Nationality';
  static const String region = 'Region';
  static const String pleaseInputBirthday = 'Please input your birthday';
  static const String pleaseSelectGender = 'Please select your gender';
  static const String addYourPhoto = 'Add your photo. (Minimum 2, Maximum 4)';
  static const String pleaseSelectNationality =
      'Please select your nationality';
  static const String pleaseSelectRegion = 'Please select your region';
  static const String pleaseInputOccupation = 'Please input your occupation';
  static const String pleaseAddMorePhotos =
      'Please add more photos (minimum 2 of photos and maximum 2 of photos)';
  static const String pleaseInputStateMessage =
      'Please input your state/introduction message';

  /// Forum Post Comment
  static const String deletePostConfirmTitle = 'Delete this post?';
  static const String deletePostConfirmMessage =
      'Are you sure you want to delete post?\nYou will not be able to recover this post.';

  static const String deleteCommentConfirmTitle = 'Delete this comment?';
  static const String deleteCommentConfirmMessage =
      'Are you sure you want to delete comment?';

  static const String notYourComment = 'This is not your comment.';

  static const String occupation = 'occupation';
  static const String occupationInputDescription = 'occupationInputDescription';
  static const String hintInputOccupation = 'Please input your occupation';

  static const String postEmptyList = 'No post found.';

  static const String commentEmptyList = 'No comments';

  static const String postCreate = 'Create';
  static const String postUpdate = 'Update';

  /// Block
  static const String blocked = 'Blocked';
  static const String blockedMessage = 'You have blocked this user.';
  static const String blockedTitleMessage = 'Blocked this user';
  static const String blockedContentMessage =
      'The contents of this user is hidden because you have blocked this user.';
  static const String blockedChatMessage =
      'You have blocked this user. Chat message is hidden.';
  // static const String blockedUserMessage = 'You have blocked this user.';

  static const String unblocked = 'Unblocked';
  static const String unblockedMessage = 'You have unblocked this user.';

  static const String disabledOnSendMessage =
      'You cannot send a message because your account is disabled.';

  /// Meetup

  static const String meetupEmptyList = 'No meetup found.';

  /// Report
  static const String reportInputTitle = 'Report';
  static const String reportInputMessage =
      'Please enter the reason for the report.';
  static const String reportInputHint = 'Reason';

  /// Phone sign in
  static const String phoneNumber = 'Phone Number';
  static const String phoneSignInHeaderTitle =
      'Please enter your phone number and tap "Get Verification Code" button.';
  static const String phoneNumberInputHint = 'Enter your phone number.';
  static const String phoneNumberInputDescription =
      'Input phone number. e.g 010 1234 5678 or 0917 1234 5678';

  static const String phoneSignInTimeoutTryAgain = 'Timeout. Please try again.';
  static const String phoneSignInGetVerificationCode = 'Get Verification Code';
  static const String phoneSignInInputSmsCode =
      'Input Verification Code and press submit button';
  static const String phoneSignInRetry = 'Retry';
  static const String phoneSignInVerifySmsCode = 'Verification Code';

  static const String invalidSmsCodeMessage = 'Invalid SMS code';

  /// Korean Sigungu Selector
  static const String selectProvince = "Select Province";
  static const String selectRegion = 'Select Region';
  static const String noSelectTedRegion = 'No selected province';

  /// DefaultUploadSelectionBottomSheet
  ///
  static const String photoUpload = 'Upload a photo';
  static const String selectPhotoFromGallery = 'Select photo from gallery';
  static const String takePhotoWithCamera = 'Take photo with camera';

  // BlockScreen
  static const String noBlockUser = 'No blocked users';
  static const String youCanBlockUserFromTheirProfilePage =
      'You can block users from their profile page';

  // SettingScreen
  static const String pushNotificationOnProfileView =
      'Push Notification on Profile View';
  static const String getNotifiedWhenSomeoneViewYourProfile =
      'Get notified when someone views your profile';
  static const String chooseYourLanguage = 'Choose your language';

  /// Used in DefaultLoginFirstScreen
  static const String loginRequredTitle = 'Login Required';
  static const String loginRequredMessage = 'Please login to continue.';
  static const String askToLoginMessage =
      'Login is required to continue. Do you want to login?';

  // Club Translation
  static const String clubCreate = '모임 만들기';
  static const String clubUpdate = '모임 수정하기';
  static const String clubName = '모임 이름';
  static const String clubNameDescription = '모임 이름을 적어주세요.';
  static const String clubPhotoDescription =
      '  모임 사진을 업로드 해 주세요. 사진 너비: 800, 사진 높이: 500';

  static const String clubDescriptionLabel = '모임 설명';
  static const String clubDescriptionInputDescription = "모임 설명을 적어주세요.";
  static const String clubUpdateMessage = '모임이 수정되었습니다.';

  static const String userNotFoundTitleOnShowPublicProfileScreen = '사용자 정보 오류';
  static const String userNotFoundMessageOnShowPublicProfileScreen =
      '사용자의 정보가 올바르지 않습니다. 탈퇴한 사용자이거나 정보가 없습니다.';

  static const String userNotFoundTitleOnSingleChat = '사용자 정보 오류';
  static const String userNotFoundMessageOnSingleChat =
      '사용자의 정보가 올바르지 않습니다. 탈퇴한 사용자이거나 정보가 없습니다.';
}
