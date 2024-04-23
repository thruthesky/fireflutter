import 'package:app_links/app_links.dart';
import 'package:fireflutter/fireflutter.dart';

class LinkService {
  static LinkService? _instance;
  static LinkService get instance => _instance ??= LinkService();

  late String urlPrefix;
  String? app;

  String get prefix {
    if (app == null) {
      return '$urlPrefix/link';
    } else {
      return '$urlPrefix/link?app=$app';
    }
  }

  init({
    required String urlPrefix,
    bool autoRedirect = false,
    Function(Map<String, String> parms)? onLinkTap,
    String? app,
  }) {
    this.urlPrefix = urlPrefix;
    this.app = app;
    if (autoRedirect) {
      final appLinks = AppLinks();

// Subscribe to all events when app is started.
// (Use allStringLinkStream to get it as [String])
      appLinks.allUriLinkStream.listen((uri) async {
        // Do something (navigation, ...)
        print('Received uri: $uri');

        final uriString = uri.toString();

        final context = FireFlutterService.instance.globalContext;

        if (context?.mounted == true) {
          if (uriString.contains('/link')) {
            final params = Uri.parse(uriString).queryParameters;
            final pid = params['pid'];
            final uid = params['uid'];
            final cid = params['cid'];

            print('pid: $pid, uid: $uid, cid: $cid');

            if (pid != null) {
              final post = await Post.getAllSummary(pid);
              print('post; $post');
              if (post != null) {
                ForumService.instance.showPostViewScreen(
                  context: context!,
                  post: post,
                );
              } else {
                dog('The post of dynamic link pid is null');
              }
            } else if (uid != null) {
              UserService.instance.showPublicProfileScreen(
                context: context!,
                uid: uid,
              );
            } else if (cid != null) {
              ChatService.instance.showChatRoomScreen(
                context: context!,
                roomId: cid,
              );
            } else {
              if (onLinkTap != null) {
                onLinkTap(params);
              }
            }
          }
        }
      });
    }
  }

  Uri generatePostLink(Post post) {
    return Uri.parse('${prefix}pid=${post.id}');
  }

  Uri generateProfileLink(String uid) {
    return Uri.parse('${prefix}uid=$uid');
  }

  Uri generateChatRoomLink(String cid) {
    return Uri.parse('${prefix}cid=$cid');
  }

  Uri generateCustomLink(String query) {
    return Uri.parse('$prefix$query');
  }
}
