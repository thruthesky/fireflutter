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
    this.selectable = true,
  });
  final String text;
  final TextStyle? style;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return selectable
        ? SelectableLinkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              _onOpen(context, link.url);
            },
            text: text,
            style: style,
            contextMenuBuilder: (_, state) =>
                AdaptiveTextSelectionToolbar.buttonItems(
              anchors: state.contextMenuAnchors,
              buttonItems: state.contextMenuButtonItems,
            ),
          )
        : Linkify(
            options: const LinkifyOptions(humanize: false),
            onOpen: (link) async {
              _onOpen(context, link.url);
            },
            text: text,
            style: style,
          );
  }

  Future<void> _onOpen(BuildContext context, String link) async {
    if (LinkService.instance.isDeepLink(link)) {
      LinkService.instance.openScreen(context, link);
    } else if (await canLaunchUrlString(link)) {
      await launchUrlString(link);
    } else {
      throw 'Could not launch $link';
    }
  }
}
