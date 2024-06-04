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
    'vi': 'Có',
    'th': 'ใช่',
    'lo': 'ແມ່ນແລ້ວ'
  };

  static Mintl no = {
    'en': 'No',
    'ko': '아니요',
    'vi': 'Không',
    'th': 'ไม่ใช่',
    'lo': 'ບໍ່'
  };

  static Mintl ok = {
    'en': 'OK',
    'ko': '확인',
    'vi': 'Ổn',
    'th': 'ตกลง',
    'lo': 'ຕົວຢ່າງ'
  };

  static Mintl error = {
    'en': 'Error',
    'ko': '오류',
    'vi': 'Lỗi',
    'th': 'เกิดข้อผิดพลาด',
    'lo': 'ຜິດພາດ'
  };

  static Mintl save = {
    'en': 'Save',
    'ko': '저장',
    'vi': 'Lưu',
    'th': 'บันทึก',
    'lo': 'ບັນທຶກ'
  };

  static Mintl stateMessage = {
    'en': 'State Message',
    'ko': '상태 메시지',
    'vi': 'Tin nhắn trạng thái',
    'th': 'ข้อความสถานะ',
    'lo': 'ຂໍ້ຄວາມສະຖານະ',
  };

  static Mintl saved = {
    'en': 'Saved.',
    'ko': '저장되었습니다.',
    'vi': 'Đã lưu',
    'th': 'บันทึกสำเร็จ',
    'lo': 'ບັນທຶກແລ້ວ'
  };

  static Mintl name = {
    'en': 'Name',
    'ko': '이름',
    'vi': 'Tên',
    'th': 'ชื่อ',
    'lo': 'ຊື່',
  };

  static Mintl cancel = {
    'en': 'Cancel',
    'ko': '취소',
    'vi': 'Hủy bỏ',
    'th': 'ยกเลิก',
    'lo': 'ຍົກເລີກ',
  };

  static Mintl close = {
    'en': 'Close',
    'ko': '닫기',
    'vi': 'Đóng',
    'th': 'ปิด',
    'lo': 'ປິດ'
  };

  static Mintl createPost = {
    'en': 'Create post',
    'ko': '글 작성',
  };

  static Mintl editPost = {
    'en': 'Edit post',
    'ko': '글 수정',
  };

  static Mintl like = {
    'en': 'Like',
    'ko': '좋아요',
  };

  static Mintl chat = {
    'en': 'Chat',
    'ko': '채팅',
  };

  static Mintl edit = {
    'en': 'Edit',
    'ko': '수정',
  };

  static Mintl delete = {
    'en': 'Delete',
    'ko': '삭제',
  };

  static Mintl share = {
    'en': 'Share',
    'ko': '공유',
  };

  static Mintl reply = {
    'en': 'Reply',
    'ko': '답글',
  };

  static Mintl bookmark = {
    'en': 'Favorite',
    'ko': '북마크',
  };

  static Mintl unbookmark = {
    'en': 'Unfavorite',
    'ko': '북마크 해제',
  };

  static Mintl bookmarkMessage = {
    'en': 'Favorite sucess',
    'ko': '북마크 완료',
  };

  static Mintl unbookmarkMessage = {
    'en': 'Unfavorite sucess',
    'ko': '북마크 해제 완료',
  };

  static Mintl block = {
    'en': 'Block',
    'ko': '차단',
    'vi': 'Chặn',
    'th': 'บล็อก',
    'lo': 'ປິດບໍ່ໃຫ້ຕົນໄປ',
  };

  static Mintl unblock = {
    'en': 'Unblock',
    'ko': '차단 해제',
    'vi': 'Bỏ chặn',
    'th': 'ยกเลิกการบล็อก',
    'lo': 'ປິດຕົນໄປ',
  };

  static Mintl report = {
    'en': 'Report',
    'ko': '신고',
    'vi': 'Báo cáo',
    'th': 'รายงาน',
    'lo': 'ລາຍງານ'
  };

  static Mintl reportReceived = {
    'en': 'Report has been received.',
    'ko': '신고가 접수되었습니다.',
  };

  static Mintl writeComment = {
    'en': 'Write a comment',
    'ko': '코멘트 작성',
  };

  static Mintl inputCommentHint = {
    'en': 'Please enter your comment',
    'ko': '댓글을 입력하세요',
  };

  /// Meetup translations
  static Mintl meetupCreate = {
    'en': 'Create meetup',
    'ko': '모임 만들기',
  };

  static Mintl meetupUpdate = {
    'en': 'Edit meetup',
    'ko': '모임 수정하기',
  };

  static Mintl meetupName = {
    'en': 'Meetup name',
    'ko': '모임 이름',
  };
  static Mintl meetupNameDescription = {
    'en': 'Please write the name of the meetup.',
    'ko': '모임 이름을 적어주세요.',
  };
  static Mintl meetupPhotoDescription = {
    'en':
        'Please upload a photo of the meetup. Photo Width: 800, Photo Height: 500',
    'ko': '  모임 사진을 업로드 해 주세요. 사진 너비: 800, 사진 높이: 500',
  };
  static Mintl meetupDescriptionLabel = {
    'en': 'Meetup description',
    'ko': '모임 설명',
  };
  static Mintl meetupDescriptionInputDescription = {
    'en': 'Please write a description of the meetup.',
    'ko': '모임 설명을 적어주세요.',
  };
  static Mintl meetupUpdateMessage = {
    'en': 'The meetup has been modified.',
    'ko': '모임이 수정되었습니다.',
  };

  static Mintl info = {
    'en': 'Info',
    'ko': '소개',
  };
  static Mintl event = {
    'en': 'Event',
    'ko': '일정',
  };

  static Mintl notice = {
    'en': 'Notice',
    'ko': '게시판',
  };
  static Mintl gallery = {
    'en': 'Gallery',
    'ko': '사진첩',
  };

  static Mintl host = {
    'en': 'Host',
    'ko': '운영자',
  };

  static Mintl members = {
    'en': 'Members',
    'ko': '회원 수',
  };

  static Mintl noOfPeople = {
    'en': 'people',
    'ko': '명',
  };

  static Mintl profileUpdate = {
    'en': 'Profile update',
    'ko': '프로필 수정',
    'vi': 'Cập nhật hồ sơ',
    'th': 'อัปเดตโปรไฟล์',
    'lo': 'ອັບເດດຂໍ້ມູນຜູ້ໃຊ້',
  };

  static Mintl contact = {
    'en': 'Contact',
    'ko': '문의하기',
  };

  static Mintl recentPhotos = {
    'en': 'Recent Photos',
    'ko': '최근 사진들',
  };

  static Mintl noRecentPhotos = {
    'en': 'There are no recent photos',
    'ko': '최근 사진이 없습니다',
  };

  static Mintl recentPosts = {
    'en': 'Recent Posts',
    'ko': '최근글',
  };

  static Mintl noRecentPosts = {
    'en': 'There are no recent posts',
    'ko': '최근 글이 없습니다.',
  };

  static Mintl reminder = {
    'en': 'Reminder',
    'ko': '알림',
  };

  static Mintl inputReminder = {
    'en': 'Input reminder',
    'ko': '입력 알림',
  };

  static Mintl createMeetupEvent = {
    'en': 'Create event',
    'ko': '일정 생성',
  };

  static Mintl addNotice = {
    'en': 'Add notice',
    'ko': '글 쓰기',
  };

  static Mintl addPhoto = {
    'en': 'Add photo',
    'ko': '글 쓰기',
  };

  static Mintl meetupAdminSetting = {
    'en': 'Admin setting',
    'ko': '관리자 설정',
  };

  static Mintl editMeetupInformation = {
    'en': 'Edit meetup info',
    'ko': '모임 정보 수정',
  };

  static Mintl leaveMeetup = {
    'en': 'Leave meetup',
    'ko': '모임 탈퇴',
  };

  static Mintl joinMeetup = {
    'en': 'Join meetup',
    'ko': '모임 가입',
  };

  static Mintl noticeManage = {
    'en': 'Update notice',
    'ko': '게시판 관리',
  };

  static Mintl closeMeetup = {
    'en': 'Close meetup',
    'ko': '모임 폐쇄',
  };

  static Mintl noEvent = {
    'en': 'There are no events',
    'ko': '일정이 없습니다.',
  };

  static Mintl joinMeetupToChat = {
    'en': 'You must join the group\nto view the chat room.',
    'ko': '모임에 가입하셔야\n채팅방을 볼 수 있습니다.',
  };

  static Mintl noNoticeYet = {
    'en': 'There are no notices yet.',
    'ko': '글을 등록 해 주세요.',
  };

  static Mintl joinMeetupToViewNotice = {
    'en': 'You must join the group\nto view the announcement.',
    'ko': '모임에 가입하셔야\n게시판을 볼 수 있습니다.',
  };

  static Mintl noUploadPhotoYet = {
    'en': 'Theres no uploaded photo yet.',
    'ko': '사진을 등록 해 주세요.',
  };

  static Mintl joinMeetupToViewGallery = {
    'en': 'You must join the group\nto view the gallery.',
    'ko': '모임에 가입하셔야\n사진첩을 볼 수 있습니다.',
  };

  static Mintl login = {
    'en': 'Login',
    'ko': '로그인',
    'vi': 'Đăng nhập',
    'th': 'เข้าสู่ระบบ',
    'lo': 'ເຂົ້າສູ່ລະບົບ',
  };

  static Mintl loginFirstToUseMeetup = {
    'en': 'To use the meetup function, you must first log in.',
    'ko': '모임 기능을 이용하기 위해서는 로그인을 먼저 하셔야합니다.',
  };

  static Mintl unsubscribed = {
    'en': 'Unsubscribe',
    'ko': '탈퇴하기',
  };

  static Mintl signup = {
    'en': 'Sign up',
    'ko': '가입하기',
  };

  static Mintl somethingWentWrong = {
    'en': 'Something went wrong!',
    'ko': '오류가 발생했습니다.',
  };

  static Mintl deleteMeetup = {
    'en': 'Delete meetup',
    'ko': '모임 삭제',
  };

  static Mintl deleteMeetupMessage = {
    'en': 'Are you sure you want to delete this meetup?',
    'ko': '정말 모임을 삭제하시겠습니까?',
  };

  static Mintl createMeetupSchedule = {
    'en': 'Create meetup schedule',
    'ko': '만남 일정 만들기',
  };

  static Mintl editMeetupSchedule = {
    'en': 'Edit meetup schedule',
    'ko': '만남 일정 수정하기',
  };

  static Mintl meetupScheduleTitle = {
    'en': 'Meetup schedule title',
    'ko': '오프라인 일정 제목',
  };

  static Mintl meetupScheduleTitleDescription = {
    'en': 'Please enter the title of the meetup schedule.',
    'ko': '오프라인 만남의 제목을 적어주세요.',
  };

  static Mintl meetupCreateSchedule = {
    'en': 'Create a schedule',
    'ko': '일정 만들기',
  };

  static Mintl meetupScheduleDateAndTime = {
    'en': 'Meetup schedule date and time',
    'ko': '만남 일정 날짜와 시간',
  };

  static Mintl selectDate = {
    'en': 'Select date',
    'ko': '날짜 선택',
  };

  static Mintl selectTime = {
    'en': 'Select time',
    'ko': '시간 선택',
  };

  static Mintl meetupSchedulePhoto = {
    'en': 'Meetup schedule photo',
    'ko': '만남 일정 사진',
  };

  static Mintl meetupScheduleName = {
    'en': 'Meetup schedule name',
    'ko': '만남 일정 이름',
  };

  static Mintl meetupScheduleNameNote = {
    'en': 'Please enter the name of the meetup schedule.',
    'ko': '오프라인 만남에 대한 이름을 적어주세요.',
  };

  static Mintl meetupSchedulePhotoNote = {
    'en': 'Please upload a photo. Photo size: 500x500',
    'ko': '모임 사진을 업로드 해 주세요. 사진 크기: 500x500',
  };

  static Mintl meetupScheduleDescription = {
    'en': 'Meetup schedule description',
    'ko': '만남 일정 설명',
  };

  static Mintl meetupScheduleDescriptionNote = {
    'en': 'Please enter the description of the meetup schedule.',
    'ko': '만남 설명을 적어주세요.',
  };

  static Mintl meetupScheduleDateOrTimeMissing = {
    'en': 'Please select a meeting date and time.',
    'ko': '모임 날짜와 시간을 선택해주세요.',
  };

  static Mintl meetupScheduleUpdated = {
    'en': 'Meetup schedule updated',
    'ko': '만남 일정이 수정되었습니다.',
  };

  static Mintl editSchedule = {
    'en': 'Edit schedule',
    'ko': '일정 수정하기',
  };

  static Mintl meetupDateAndTime = {
    'en': 'Meetup date and time',
    'ko': '모임 날짜 & 시간',
  };

  // TODO: ko translation club
  static Mintl meetupMembershipRequired = {
    'en': 'Meetup membership required.',
    'ko': '클럽 가입 필요',
  };

  static Mintl meetupMembershipRequiredMessage = {
    'en': 'Please join the meetup first.',
    'ko': '모임에 먼저 가입을 해 주세요.',
  };

  static Mintl meetupCancelledAttendance = {
    'en': 'Attendance cancelled.',
    'ko': '참석을 취소했습니다.',
  };

  static Mintl meetupCancelAttendance = {
    'en': 'Cancel attendance',
    'ko': '참석 취소하기',
  };

  static Mintl meetupCancelAttendanceMessage = {
    'en': 'Meetup membership required.',
    'ko': '클럽 가입 필요',
  };

  static Mintl signUpFirstThenApplyToAttend = {
    'en': 'Please sign up for the meetup first and then apply to attend.',
    'ko': '모임에 먼저 가입을 하신 다음, 참석 신청을 주세요.',
  };

  static Mintl applyToAttendConfirmed = {
    'en': 'Apply to attend confirmed',
    'ko': '참석 신청했습니다.',
  };

  static Mintl applyToAttend = {
    'en': 'Apply to attend',
    'ko': '참석 신청하기',
  };

  static Mintl listOfAttendees = {
    'en': 'List of Applicants to Attend',
    'ko': '참석 신청자 목록',
  };

  static Mintl noApplicantsYet = {
    'en': 'There are no applicants to attend, yet.',
    'ko': '참석 신청자가 없습니다.',
  };

  static Mintl meetupAdminSettings = {
    'en': 'Meetup admin settings',
    'ko': '모임 관리자 설정',
  };

  static Mintl recommend = {
    'en': 'Recommend',
    'ko': '추천',
  };

    static Mintl recommendWithCount = {
    'en': 'Recommend #count',
    'ko': '추천 #count',
  };

  static Mintl inputRecommendHint = {
    'en':
        'Input number only. Higher number will shown first. 0 will remove the recommendation.',
    'ko': '숫자만 입력하세요. 높은 숫자가 먼저 표시됩니다. 0은 권장 사항을 제거합니다.',
  };

  static Mintl recommendRemove = {
    'en': 'Remove recommendation',
    'ko': '추천 삭제',
  };

  static Mintl recommendRemoveMessage = {
    'en': 'Are you sure you want to remove this from recommendations list?',
    'ko': '추천 목록에서 이 항목을 삭제하시겠습니까?',
  };

  /// EO meetups translations

  ///////////////////////////////////////////////////////////////////

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
  // static const String login = 'Login';
  static const String next = 'Next';
  static const String prev = 'Prev';
  static const String back = 'Back';
  // static const String like = 'Like';
  static const String likes = 'Likes';
  // static const String bookmark = 'Favorite';
  // static const String bookmarkMessage = 'Favorite sucess';
  // static const String unbookmark = 'Unfavorite';
  // static const String unbookmarkMessage = 'Unfavorite success';
  static const String thereAreNoBookmarksInTheList =
      'There are no bookmarks in the list.';

  // static const String share = 'Share';

  static const String inputTitle = 'Input title';
  static const String inputContent = 'Input content';

  /// Label, texts, buttons,
  static const String dismiss = 'dismiss';

  /// Chat
  ///
  // static const String chat = 'Chat';
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
  static const String readMore = 'Read More';
  static const String viewProfile = 'View Profile';
  // static const String reply = 'Reply';
  static const String deleteMessage = 'Delete Message';
  static const String deleteMessageConfirmation =
      "Are you sure you want to delete this message? This action cannot be undone.";
  static const String blockUser = 'Block User';
  static const String unblockUser = 'Unblock User';
  static const String blockUserChatConfirmation =
      "Are you sure you want to block this user from the chat room?";
  static const String unblockUserChatConfirmation =
      "Are you sure you want to unblock this user from the chat room? This person may see all the messages in the chat room.";
  static const String noPermission = 'No permission.';
  static const String noPermissionModifyChatRoom =
      'You do not have permission to modify the chat room.';
  static const String newChat = 'New Chat';
  static const String chatRoomSettings = 'Chat Room Settings';
  static const String chatRoomName = 'Chat Room Name';
  static const String chatRoomDescription = 'Chat Room Description';
  static const String passwordToJoin = 'Password to Join';
  static const String leaveEmptyPasswordIfNotRequired =
      'Empty means no password.';
  static const String uploadChatRoomIcon = 'Upload Chat Room Icon';
  static const String openChat = 'Open Chat';
  static const String anyoneCanJoinChat = 'Anyone can join.';
  static const String verifiedMembersOnly = 'Verified members only';
  static const String onlyVerifiedMembersCanJoinChat =
      'Must be verified to join.';
  static const String urlEntryOnlyForVerified = 'URL Entry Only for Verified';
  static const String onlyVerifiedMembersCanEnterViaUrl =
      'Only verified members can enter via URL';
  static const String photoUploadOnlyForVerified = "Upload Only for Verified";
  static const String onlyVerifiedMembersCanUploadPhoto =
      "Only verified can upload photos.";
  static const String pleaseEnterChatRoomNameAndDescription =
      'Please enter chat room name and description.';
  static const String create = "Create";
  // static const String edit = "Edit";

  /// User
  static const String setting = 'Setting';
  // static const String block = 'Block';
  // static const String unblock = 'Unblock';
  // static const String report = 'Report';
  static const String leave = 'Leave';
  // static const String stateMessage = 'State Message';
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
  // static const String profileUpdate = 'Profile Update';
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
  // static const String clubCreate = '모임 만들기';
  // static const String clubUpdate = '모임 수정하기';
  // static const String clubName = '모임 이름';
  // static const String clubNameDescription = '모임 이름을 적어주세요.';
  // static const String clubPhotoDescription =
  // '  모임 사진을 업로드 해 주세요. 사진 너비: 800, 사진 높이: 500';

  // static const String clubDescriptionLabel = '모임 설명';
  // static const String clubDescriptionInputDescription = "모임 설명을 적어주세요.";
  // static const String clubUpdateMessage = '모임이 수정되었습니다.';

  static const String userNotFoundTitleOnShowPublicProfileScreen = '사용자 정보 오류';
  static const String userNotFoundMessageOnShowPublicProfileScreen =
      '사용자의 정보가 올바르지 않습니다. 탈퇴한 사용자이거나 정보가 없습니다.';

  static const String userNotFoundTitleOnSingleChat = '사용자 정보 오류';
  static const String userNotFoundMessageOnSingleChat =
      '사용자의 정보가 올바르지 않습니다. 탈퇴한 사용자이거나 정보가 없습니다.';
}
