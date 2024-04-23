import 'package:fireflutter/fireflutter.dart';

class LinkService {
  static LinkService? _instance;
  static LinkService get instance => _instance ??= LinkService();

  late String urlPrefix;

  init({
    required String urlPrefix,
    bool autoRedirect = true,
  }) {
    this.urlPrefix = urlPrefix;
    if (autoRedirect) {
      ///
//       final appLinks = AppLinks();

// // Subscribe to all events when app is started.
// // (Use allStringLinkStream to get it as [String])
//       appLinks.allUriLinkStream.listen((uri) {
//         // Do something (navigation, ...)

//         UserService.instance
//             .showPublicProfileScreen(context: context, uid: uid);
//         ForumService.instance.showPostViewScreen(context: context, post: post);
//         ChatService.instance.showChatRoomScreen(
//           context: context,
//           uid: uid,
//           roomId: roomId,
//           room: room,
//         );
//       });
    }
  }

  Uri generatePostLink(Post post) {
    return Uri.parse('$urlPrefix/link?pid=${post.id}');
  }

  Uri generateProfileLink(String uid) {
    return Uri.parse('$urlPrefix/link?uid=$uid');
  }

  Uri generateChatRoomLink(String uid) {
    return Uri.parse('$urlPrefix/link?cid=$uid');
  }
}
