import 'package:fireship/fireship.dart';

class Folder {
  Folder._();
  static const String admins = 'admins';
  static const String chatJoins = 'chat-joins';
  static const String chatMessages = 'chat-messages';
  static const String chatRooms = 'chat-rooms';
  static const String userFcmTokens = 'user-fcm-tokens';
  static const String userPhotos = 'user-photos';
  static const String userProfilePhotos = 'user-profile-photos';
  static const String users = 'users';

  static const String reports = 'reports';
}

class Field {
  Field._();

  static const String disabled = 'disabled';

  /// Fields and constants
  static const String uid = 'uid';
  static const String name = 'name';
  static const String description = 'description';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String isDisabled = 'isDisabled';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  static const String displayName = 'displayName';
  static const String birthDay = 'birthDay';
  static const String birthMonth = 'birthMonth';
  static const String birthYear = 'birthYear';

  static const String photoUrl = 'photoUrl';
  static const String hasPhotoUrl = 'hasPhotoUrl';
  static const String profileViewNotification = 'profileViewNotification';

  static const String order = 'order';
  static const String singleChatOrder = 'singleChatOrder';
  static const String groupChatOrder = 'groupChatOrder';
  static const String openGroupChatOrder = 'openGroupChatOrder';
  static const String newMessage = 'newMessage';

  static const String text = 'text';
  static const String url = 'url';
  static const String roomId = 'roomId';
  static const String users = 'users';
  static const String master = 'master';
  static const String noOfUsers = 'noOfUsers';
  static const String isVerified = 'isVerified';
  static const String isVerifiedOnly = 'isVerifiedOnly';
  static const String urlVerified = 'urlVerified';
  static const String uploadVerified = 'uploadVerified';

  static const String iconUrl = 'iconUrl';

  static const String profileBackgroundImageUrl = 'profileBackgroundImageUrl';

  static const String blocks = 'blocks';
}

class Path {
  Path._();

  /// User
  static const String users = Folder.users;
  static const String userProfilePhotos = Folder.userProfilePhotos;

  /// Chat
  static const String chatMessages = Folder.chatMessages;
  static String chatRoomUsersAt(roomId, uid) => '${Folder.chatRooms}/$roomId/${Field.users}/$uid';

  static const String joins = Folder.chatJoins;
  static String join(String myUid, String roomId) => '$joins/$myUid/$roomId';

  static String get myReports => '${Folder.reports}/$myUid';
}
