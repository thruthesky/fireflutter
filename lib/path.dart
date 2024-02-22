import 'package:fireship/fireship.dart';

/// Path
///
class Path {
  Path._();

  /// User
  static const String users = Folder.users;
  static String user(String uid) => '${Folder.users}/$uid';
  static String userField(String uid, String field) => '${user(uid)}/$field';
  static const String userLikes = Folder.userLikes;
  static const String userWhoILike = Folder.userWhoILike;
  static String like(String a, String b) => '$userWhoILike/$a/$b';
  static const String userWhoLikeMe = Folder.userLikes;
  static const String userProfilePhotos = Folder.userProfilePhotos;

  static String phoneNumber =
      '${Folder.userPrivate}/$myUid/${Field.phoneNumber}';
  static String email = '${Folder.userPrivate}/$myUid/${Field.email}';

  /// Forum
  static const String posts = Folder.posts;
  static const String postSubscriptions = Folder.postSubscriptions;
  static String postSubscription(String category) =>
      '$postSubscriptions/$category/$myUid';
  static const String postSummaries = Folder.postSummaries;
  static const String postAllSummaries = Folder.postAllSummaries;

  /// Retuns the path of comments of the post.
  /// i.e. /comments/<postId>
  static String comments(String postId) => '${Folder.comments}/$postId';
  static String comment(String postId, String commentId) =>
      '${comments(postId)}/$commentId';

  /// Chat
  static const String chatMessages = Folder.chatMessages;
  static String chatRoomUsersAt(roomId, uid) =>
      '${Folder.chatRooms}/$roomId/${Field.users}/$uid';
  static String chatRoomName(roomId) =>
      '${Folder.chatRooms}/$roomId/${Field.name}';
  static String chatRoomIconUrl(roomId) =>
      '${Folder.chatRooms}/$roomId/${Field.iconUrl}';

  static const String joins = Folder.chatJoins;
  static String join(String myUid, String roomId) => '$joins/$myUid/$roomId';

  static String get myReports => '${Folder.reports}/$myUid';

  static String categorySubscription(String category) =>
      '${Folder.postSubscriptions}/$category/$myUid';

  /// Bookmark ( = Favorite )
  static String bookmarkUser(String otherUserUid) =>
      '${Folder.bookmarks}/$myUid/$otherUserUid';
  static String bookmarkPost(String postId) =>
      '${Folder.bookmarks}/$myUid/$postId';
  static String bookmarkComment(String commentId) =>
      '${Folder.bookmarks}/$myUid/$commentId';
  static String bookmarkChatRoom(String roomId) =>
      '${Folder.bookmarks}/$myUid/$roomId';
}
