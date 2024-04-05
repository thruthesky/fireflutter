import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkifyText extends StatelessWidget {
  const LinkifyText(
    this.text, {
    super.key,
    this.style,
  });
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SelectableLinkify(
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
      contextMenuBuilder: (_, state) =>
          AdaptiveTextSelectionToolbar.buttonItems(
        anchors: state.contextMenuAnchors,
        buttonItems: state.contextMenuButtonItems,
      ),
    );
  }
}
