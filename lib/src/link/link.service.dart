import 'package:app_links/app_links.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/scheduler.dart';

/// [LinkService] is used to generate links for posts, profiles, chat rooms, and custom links.
class LinkService {
  static LinkService? _instance;
  static LinkService get instance => _instance ??= LinkService();

  /// [initialized] is used to check if the [init] method is called.
  bool initialized = false;
  late String urlPrefix;
  String? app;

  String get prefix {
    if (app == null) {
      return '$urlPrefix/link?';
    } else {
      return '$urlPrefix/link?app=$app&';
    }
  }

  init({
    required String urlPrefix,
    bool autoRedirect = false,
    Function(Map<String, String> parms)? onLinkTap,
    String? app,
  }) {
    initialized = true;
    this.urlPrefix = urlPrefix;
    this.app = app;
    if (autoRedirect) {
      final appLinks = AppLinks();

// Subscribe to all events when app is started.
// (Use allStringLinkStream to get it as [String])
      /// 주의, Firebase Auth 를 구현할 때, 여기에 떨어진다.
      /// 특히, Firebase Auth 에 `/link` 문자열이 들어 있다. 예) ://firebaseauth/link?deep_link_id=...
      appLinks.allUriLinkStream.listen((uri) async {
        // Do something (navigation, ...)
        dog('Received uri: $uri');

        // Added a SchedulerBinding here but I am not sure if this actually helps here.
        // Whatever, we need to ensure that ForumService, ChatService, UserService, etc. are
        // initialized before we use them because some of the may have some sort of customization
        // that depends on the developers.
        // - 2024-06-12 @withcenter-dev2
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          final uriString = uri.toString();
          final context = FireFlutterService.instance.globalContext;

          if (context?.mounted == true) {
            if (uriString.contains('/link')) {
              final params = Uri.parse(uriString).queryParameters;
              if (params.isEmpty) return;

              /// 구글 FirebaseAuth 로그인 시, deep_link_id 가 들어오는데, 그냥 리턴한다.
              if (params['deep_link_id'] != null) {
                dog('-- appLinks.allUriLinkScream.listen() param has deep_link_id. It is for Firebase Auth. Just return.');
                return;
              }
              final pid = params['pid'];
              final uid = params['uid'];
              final cid = params['cid'];
              final page = params['page'];

              print('pid: $pid, uid: $uid, cid: $cid, page: $page');

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
