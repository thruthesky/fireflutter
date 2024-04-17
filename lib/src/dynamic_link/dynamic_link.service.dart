import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Fireflutter provides a DynamicLinkService
/// that can be used to handle dynamic links.
class DynamicLinkService {
  static DynamicLinkService? _instance;
  static DynamicLinkService get instance =>
      _instance ??= DynamicLinkService._();
  DynamicLinkService._();

  /// AppLinks instance
  late final AppLinks _appLinks;

  StreamSubscription<Uri>? _appLinkStream;

  /// BuildContext, Preferrably, the globalContext
  late BuildContext context;

  /// Path for post links
  /// For example, "dynamiclink.com/post?category=news&postId=1234567890"
  String postPath = "/post";

  /// Path for user links
  /// For example, "dynamiclink.com/user?uid=1234567890"
  String userPath = "/user";

  /// This can be used for custom dynamic links
  /// The [uri] is the the link that has the path and/or
  /// queryParameters
  Function(Uri uri)? onLink;

  /// Scheme for dynamic links
  /// For example, "https" for "https://dynamiclink.com/post?category=news&postId=1234567890"
  String scheme = "https";

  /// The host that is used to make the links.
  String host = "";

  /// The application name that may appear for
  /// links' preview.
  String appName = "";

  /// The application's Icon's URL that may appear for
  /// links' preview.
  /// For example, "https://example.com/icon.png"
  String appIconLink = "";

  /// Initialization
  ///
  /// This is best called when the app is ready.
  ///
  /// For post links, the link has path of "/post"
  /// For user links, the link has path of "/user"
  Future<void> init({
    /// Required to open certain screens.
    /// Preferrably, give the globalContext
    required BuildContext context,

    /// This can be used for custom dynamic links
    Function(Uri uri)? onLink,

    /// Path for post links
    /// For example, use "/post" for "dynamiclink.com/post?category=news&postId=1234567890"
    String postPath = "/post",

    /// Path for user links
    /// For example, use "/user" for "dynamiclink.com/user?uid=1234567890"
    String userPath = "/user",

    /// Scheme for dynamic links
    /// For example, "https" for "https://dynamiclink.com/post?category=news&postId=1234567890"
    String scheme = "https",

    /// The host that is used to make the links.
    /// This is required because we wont be able to create links without a host.
    required String host,

    /// This will be displayed as the application name in Dynamic Link
    String? appName,

    /// This link will display the Icon in the dynamic link.
    String? appIconLink,
  }) async {
    _appLinks = AppLinks();
    this.context = context;
    this.onLink = onLink;
    this.postPath = postPath;
    this.userPath = userPath;
    this.scheme = scheme;
    this.host = host;
    this.appName = appName ?? "";
    this.appIconLink = appIconLink ?? "";

    // To prevent multi-listener in case dev called init again.
    if (_appLinkStream != null) await _appLinkStream!.cancel();

    // Subscribe to all events when app is started.
    _appLinkStream = _appLinks.allUriLinkStream.listen((uri) async {
      dog("=======================>>>> AppLink: $uri");
      dog("queryParameters: ${uri.queryParameters}");
      dog("path: ${uri.path}");
      await showScreenFromUri(uri);
    });
  }

  /// Depending on the path, show the screen accordingly.
  showScreenFromUri(Uri uri) async {
    if (uri.path == postPath) return await _showPostScreen(uri);
    if (uri.path == userPath) return await _showUserScreen(uri);
    if (onLink != null) return await onLink!(uri);
    dog("Something went wrong! Unknown path: ${uri.path}");
  }

  /// Shows Post Screen using category and post ID
  _showPostScreen(Uri uri) async {
    final category = uri.queryParameters["category"];
    final postId = uri.queryParameters["postId"];
    if (postId == null || category == null) return;
    final post = await Post.get(category: category, id: postId);
    if (post != null && context.mounted) {
      ForumService.instance.showPostViewScreen(context: context, post: post);
    }
  }

  /// Shows Public Profile Screen using uid
  _showUserScreen(Uri uri) {
    final uid = uri.queryParameters["uid"];
    if (uid == null) return;
    if (context.mounted) {
      UserService.instance.showPublicProfileScreen(context: context, uid: uid);
    }
  }

  String createUserLink(User user) {
    final uri = createLink(
      path: userPath,
      queryParameters: {
        "uid": user.uid,
        "previewImageLink": user.photoUrl,
        "previewText": user.displayName,
        "appName": appName,
        "appIconLink": appIconLink,
      },
    );
    return uri.toString();
  }

  String createPostLink(Post post) {
    final uri = createLink(
      path: postPath,
      queryParameters: {
        "category": post.category,
        "postId": post.id,
        "previewImageLink": post.urls.isNotEmpty ? post.urls.first : "",
        "previewText": post.title,
        "appName": appName,
        "appIconLink": appIconLink,
      },
    );
    return uri.toString();
  }

  /// Creates the dynamic link
  Uri createLink({String path = "", Map<String, String>? queryParameters}) {
    final uri = Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: queryParameters,
    );
    return uri;
  }
}
