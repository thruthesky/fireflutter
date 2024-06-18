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
  });
  final String text;
  final bool selectable;
  final TextStyle? style;

  /// adding this so the link can be customized depending where it will be displayed
  final TextStyle? linkStyle;

  @override
  Widget build(BuildContext context) {
    return selectable
        ? SelectableLinkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              if (await canLaunchUrlString(link.url)) {
                await launchUrlString(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: text,
            style: style,
            linkStyle: linkStyle,
            contextMenuBuilder: (_, state) =>
                AdaptiveTextSelectionToolbar.buttonItems(
              anchors: state.contextMenuAnchors,
              buttonItems: state.contextMenuButtonItems,
            ),
          )
        : Linkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              if (await canLaunchUrlString(link.url)) {
                await launchUrlString(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: text,
            style: style,
            linkStyle: linkStyle,
          );
  }
}
