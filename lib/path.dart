import 'package:fireship/fireship.dart';

class Path {
  Path._();

  /// User
  static const String users = Folder.users;
  static const String userProfilePhotos = Folder.userProfilePhotos;

  /// Chat
  static const String chatMessages = Folder.chatMessages;
  static String chatRoomUsersAt(roomId, uid) => '${Folder.chatRooms}/$roomId/${Field.users}/$uid';
  static String chatRoomName(roomId) => '${Folder.chatRooms}/$roomId/${Field.name}';
  static String chatRoomIconUrl(roomId) => '${Folder.chatRooms}/$roomId/${Field.iconUrl}';

  static const String joins = Folder.chatJoins;
  static String join(String myUid, String roomId) => '$joins/$myUid/$roomId';

  static String get myReports => '${Folder.reports}/$myUid';
}
