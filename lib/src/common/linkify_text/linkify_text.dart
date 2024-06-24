import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// LinkifyText
///
/// [selectable] true: SelectableLinkify, false: Linkify
class LinkifyText extends StatelessWidget {
  const LinkifyText(
    this.text, {
    super.key,
    this.style,
    this.linkStyle,
    this.selectable = true,
    this.textWidthBasis = TextWidthBasis.longestLine,
  });
  final String text;
  final bool selectable;
  final TextStyle? style;

  /// [Linkify] sets [TextWidthBasis.parent] as default so it takes all the spaces
  /// up to the parents max width.
  ///
  /// To prevent this, [TextWidthBasis.longestLine] will remove the space up to the
  /// [Text] longest line. As flutter said, a common use case for this is chat bubbles.
  ///
  /// Try to change the [longestLine] to [parent] and see the difference.
  final TextWidthBasis textWidthBasis;

  /// To customize the link depending where it will be displayed
  final TextStyle? linkStyle;

  @override
  Widget build(BuildContext context) {
    return selectable
        ? SelectableLinkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              await _onOpen(context, link.url);
            },
            text: text,
            style: style,
            linkStyle: linkStyle,
            contextMenuBuilder: (_, state) =>
                AdaptiveTextSelectionToolbar.buttonItems(
              anchors: state.contextMenuAnchors,
              buttonItems: state.contextMenuButtonItems,
            ),
            textWidthBasis: textWidthBasis,
          )
        : Linkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              await _onOpen(context, link.url);
            },
            text: text,
            style: style,
            linkStyle: linkStyle,
            textWidthBasis: textWidthBasis,
          );
  }

  Future<void> _onOpen(BuildContext context, String link) async {
    if (canLaunchDynamicLink(link)) {
      LinkService.instance.openScreen(context, link);
    } else if (await canLaunchUrlString(link)) {
      await launchUrlString(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  bool canLaunchDynamicLink(String link) =>
      LinkService.instance.initialized && LinkService.instance.isDeepLink(link);
}
