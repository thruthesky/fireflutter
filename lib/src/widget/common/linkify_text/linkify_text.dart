import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkifyText extends StatelessWidget {
  const LinkifyText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
  }) : super(key: key);
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Linkify(
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
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
