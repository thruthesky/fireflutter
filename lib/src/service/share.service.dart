import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';

class ShareService {
  static ShareService? _instance;

  static ShareService get instance => _instance ??= ShareService._();

  ShareService._();

  showBottomSheet({
    List<Widget> actions = const [],
  }) {
    final context = FireFlutterService.instance.context;
    showModalBottomSheet(
      context: context,
      barrierColor: Theme.of(context).colorScheme.secondary.withOpacity(.5).withAlpha(110),
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.symmetric(horizontal: sizeSm),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 28,
              margin: const EdgeInsets.symmetric(vertical: sizeSm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.secondary.withAlpha(80),
              ),
            ),
            const TextField(),
            Expanded(
              child: ListView(
                children: const [
                  Text("Display your followers"),
                ],
              ),
            ),
            Wrap(
              spacing: 16,
              children: actions,
            ),
            const SafeArea(
                child: SizedBox(
              height: sizeMd,
            ))
          ],
        ),
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
    required String link,
    required String uriPrefix,
    required appId,
    String title = "Title",
    String description = "Description",
    String? imageUrl,
  }) async {
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse(link),
        uriPrefix: uriPrefix,
        androidParameters: AndroidParameters(packageName: appId),
        iosParameters: IOSParameters(bundleId: appId),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: title,
          description: description,
          imageUrl: imageUrl == null ? null : Uri.parse(imageUrl),
        ),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: true,
        ));

    final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);

    return dynamicLink.shortUrl.toString();
  }
}
