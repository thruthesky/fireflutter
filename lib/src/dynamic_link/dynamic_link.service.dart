import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

/// See readme.md
class DynamicLinkService {
  static DynamicLinkService? _instance;
  static DynamicLinkService get instance {
    _instance ??= DynamicLinkService();
    return _instance!;
  }

  String _dynamicLinkDomain = '';
  String get dynamicLinkDomain => _dynamicLinkDomain;

  String _dynamicLinkWebDomain = '';

  String _androidAppId = '';
  String _iosBundleId = '';

  int _androidMinimumVersion = 0;
  String _iosMinimumVersion = '0';

  init({
    required dynamicLinkDomain,
    required dynamicLinkWebDomain,
    String androidAppId = '',
    String iosBundleId = '',
    int androidMinimumVersion = 0,
    String iosMinimumVersion = '0',
  }) async {
    _dynamicLinkDomain = dynamicLinkDomain;
    _dynamicLinkWebDomain = dynamicLinkWebDomain;
    _androidAppId = androidAppId;
    _androidMinimumVersion = androidMinimumVersion;
    _iosBundleId = iosBundleId;
    _iosMinimumVersion = iosMinimumVersion;
  }

  // Get any initial links
  Future<PendingDynamicLinkData?> get initialLink =>
      FirebaseDynamicLinks.instance.getInitialLink();

  listen(Function(Uri?) callback) {
    /// Initialize dynamic link listeners
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;

      if (deepLink != null) {
        callback(deepLink);
      }
    }, onError: (e) {
      // print(e.toString());
    });
  }

  /// Create dynamic link
  ///
  /// [short] true by default.
  /// [path] path can also includes query. Just like a URL.
  ///
  /// [webDomain] web domain that the dynamic link will redirect besides the default [dynamicLinkWebDomain]
  /// initially set on `init()`, [webDomain] must also be included on the URL whitelist on firebase console dynamic links settings.
  ///
  /// [title], [description] and [imageUrl] can be provided for social meta tags.
  ///
  /// [campaign], [source], [medium], [content] and [term] are used for google analytics.
  /// ``` dart
  ///   DynamicLinks.instance.create(
  ///     path: '/forum?postIdx=123',
  ///     title: 'sample title',
  ///     description: 'this is content',
  ///     imageUrl: '...',
  ///   )
  /// ```
  Future<Uri> create({
    bool short = true,
    String path = '/',
    String? webDomain,
    String? title,
    String? description,
    String? imageUrl,
    String? campaign,
    String? source,
    String? medium,
    String? content,
    String? term,
  }) async {
    String _link = '$_dynamicLinkWebDomain';
    if (webDomain != null) _link = webDomain;
    if (path.split('').first != '/') path = '/$path';
    if (path != '') _link = '$_link$path';

    if (title != null) {
      title = title.length > 255 ? title.substring(0, 255) : title;
    }

    if (kIsWeb) {
      final dio = Dio();
      final res = await dio.post(
          'https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyDYN1v4RwGoRmR31IfbPDu-92YAEyysv4M',
          data: {
            "dynamicLinkInfo": {
              "domainUriPrefix": _dynamicLinkDomain,
              "link": '$_dynamicLinkWebDomain$path',
              "androidInfo": {"androidPackageName": _androidAppId},
              "iosInfo": {"iosBundleId": _iosBundleId}
            },
            "suffix": {
              "option": "SHORT",
            }
          });

      return Uri.parse(res.data['shortLink']);
    } else {
      DynamicLinkParameters parameters = DynamicLinkParameters(
        /// this should be the same as the one on the firebase console.
        uriPrefix: _dynamicLinkDomain,
        link: Uri.parse(_link),

        /// android package name can be found at "android/app/build.grade" defaultConfig.applicationId.
        /// set which application minimum version to support dynamic links.
        androidParameters: AndroidParameters(
          packageName: _androidAppId,
          minimumVersion: _androidMinimumVersion,
        ),

        /// iOs application bundle ID.
        /// set which application minimum version to support dynamic links.
        iosParameters: IOSParameters(
          bundleId: _iosBundleId,
          minimumVersion: _iosBundleId != '' ? _iosMinimumVersion : null,
        ),

        socialMetaTagParameters: SocialMetaTagParameters(
          title: title,
          description: description,
          imageUrl: imageUrl != null ? Uri.tryParse(imageUrl) : null,
        ),

        googleAnalyticsParameters: GoogleAnalyticsParameters(
          campaign: campaign,
          source: source,
          medium: medium,
          content: content,
          term: term,
        ),
      );

      Uri url;
      if (short) {
        final ShortDynamicLink shortLink =
            await FirebaseDynamicLinks.instance.buildShortLink(
          parameters,
        );
        url = shortLink.shortUrl;
      } else {
        url = await FirebaseDynamicLinks.instance.buildLink(parameters);
      }

      return url;
    }
  }
}
