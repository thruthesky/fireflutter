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
  late AppLinks _appLinks;

  /// For dynamic links, after the host name, the path should begin with "/link"
  /// For example, "dynamiclink.com/link/post?category=news&postId=1234567890"
  final String _linkPath = "/link";

  StreamSubscription<Uri>? _appLinkStream;

  /// The context that is used to show screens
  BuildContext get context {
    if (FireFlutterService.instance.globalContext == null) {
      throw FireFlutterException(
        'dynamic_link/globalContext-required',
        'To use dynamic link, you need to set FireFlutterService.instance.globalContext.',
      );
    }
    return FireFlutterService.instance.globalContext!;
  }

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

  /// Default value for appName in link
  ///
  /// The application name that may appear for
  /// links' preview.
  String appName = "";

  /// Default value for appIconLink in link
  ///
  /// The application's Icon's URL that may appear for
  /// links' preview.
  /// For example, "https://example.com/icon.png"
  String appIconLink = "";

  /// Default value for appleAppId in link
  ///
  /// This can help when the app is not installed
  /// on the receiver of the dynamic link's device.
  String appleAppId = "";

  /// Default value for appStoreUrl
  ///
  String appStoreUrl = "";

  /// Default value for playStoreUrl in link
  ///
  String playStoreUrl = "";

  /// Default value for webUrl in link
  ///
  String webUrl = "";

  /// This is the urlScheme used for deeplink for Android
  /// and custom URL Scheme for iOS
  String customUrlScheme = "";

  /// Initialization
  ///
  /// This is best called when the app is ready.
  ///
  /// For post links, the link has path of "/post"
  /// For user links, the link has path of "/user"
  Future<void> init({
    Function(Uri uri)? onLink,
    String postPath = "/post",
    String userPath = "/user",
    String scheme = "https",
    String customUrlScheme = "",
    required String host,
    String? appName,
    String? appIconLink,
  }) async {
    _appLinks = AppLinks();
    this.onLink = onLink;
    this.postPath = postPath;
    this.userPath = userPath;
    this.scheme = scheme;
    this.customUrlScheme = customUrlScheme;
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
      dog("host: ${uri.host}");
      dog("scheme: ${uri.scheme}");
      await showScreenFromUri(uri);
    });
  }

  /// Depending on the path, show the screen accordingly.
  showScreenFromUri(Uri uri) async {
    if (uri.path == "$_linkPath$postPath") return await _showPostScreen(uri);
    if (uri.path == "$_linkPath$userPath") return await _showUserScreen(uri);
    if (onLink != null) return await onLink!(uri);
    throw Exception("Link: Something is wrong! Unknown path: ${uri.path}");
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

  /// Creates Fireflutter's default dynamic link for a user share.
  Uri createUserLink(User user) {
    final queryParameters = DynamicLinkQueryParameters(
      previewImageLink: user.photoUrl,
      previewText: user.displayName,
      appName: appName,
      appIconLink: appIconLink,
      appleAppId: appleAppId,
      uid: user.uid,
    );
    final uri = createLink(
      path: userPath,
      queryParameters: queryParameters,
    );
    return uri;
  }

  /// Creates Fireflutter's default dynamic link for a post share.
  Uri createPostLink(Post post) {
    final queryParameters = DynamicLinkQueryParameters(
      previewImageLink: post.urls.isNotEmpty ? post.urls.first : "",
      previewText: post.title,
      appName: appName,
      appIconLink: appIconLink,
      postId: post.id,
      appleAppId: appleAppId,
      category: post.category,
    );
    final uri = createLink(
      path: postPath,
      queryParameters: queryParameters,
    );
    return uri;
  }

  /// Using this, this will prevent developer to type
  /// some default fields over and over.
  DynamicLinkQueryParameters get _defaultQueryParametersValues =>
      DynamicLinkQueryParameters(
        appName: appName,
        appIconLink: appIconLink,
        appleAppId: appleAppId,
        playStoreUrl: playStoreUrl,
        appStoreUrl: appStoreUrl,
        webUrl: webUrl,
        customUrlScheme: customUrlScheme,
      );

  /// Creates the dynamic link
  ///
  /// [path] must be with "/" at the start.
  /// For example, "/post", or "/user".
  ///
  /// [queryParameters] can be null but
  /// it is recommended to add the preview
  /// values for better preview, and the values
  /// that will be needed to open screens.
  ///
  Uri createLink({
    String path = "",
    DynamicLinkQueryParameters? queryParameters,
  }) {
    // Let the queryParameters input replace/add
    // values to the map.
    final mergedQueryParameters = {
      ..._defaultQueryParametersValues.toMap(),
      ...?queryParameters?.toMap(),
    };
    final uri = Uri(
      scheme: scheme,
      host: host,
      // Must have "/link"
      path: "$_linkPath$path",
      queryParameters: mergedQueryParameters,
    );
    return uri;
  }
}
