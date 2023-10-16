import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';

class ShareService {
  static ShareService? _instance;

  static ShareService get instance => _instance ??= ShareService._();

  ShareService._();

  String uriPrefix = "";
  String appId = "";

  init({
    required String uriPrefix,
    required String appId,
  }) {
    this.uriPrefix = uriPrefix;
    this.appId = appId;
  }

  showBottomSheet({
    List<Widget> actions = const [],
    String? text,
  }) {
    final context = FireFlutterService.instance.context;
    showModalBottomSheet(
      context: context,
      barrierColor: Theme.of(context)
          .colorScheme
          .secondary
          .withOpacity(.5)
          .withAlpha(110),
      isDismissible: true,
      enableDrag: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.96,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => ShareBottomSheet(
        actions: actions,
        text: text,
      ),
    );
  }

  /// Generate short dynamic link.
  ///
  /// Note that, when [forceRedirectEnabled] is true, it will open the app
  /// without showing the preview page on iOS. But it shows page not found
  /// when the link is shared and tapped in Discord app. It was working
  /// fine on other apps so far.
  ///
  Future<String> dynamicLink({
    required String type,
    required String id,
    String? uriPrefix,
    String? appId,
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse("${this.uriPrefix}?type=$type&id=$id"),
        uriPrefix: uriPrefix ?? this.uriPrefix,
        androidParameters: AndroidParameters(packageName: appId ?? this.appId),
        iosParameters: IOSParameters(bundleId: appId ?? this.appId),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: title,
          description: description,
          imageUrl: imageUrl == null ? null : Uri.parse(imageUrl),
        ),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: true,
        ));

    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    ActivityService.instance.onShare(type: type, id: id);
    return dynamicLink.shortUrl.toString();
  }
}
