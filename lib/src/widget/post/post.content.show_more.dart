import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:parsed_readmore/parsed_readmore.dart';
import 'package:url_launcher/url_launcher.dart';

class PostContentShowMore extends StatelessWidget {
  const PostContentShowMore({
    super.key,
    required this.post,
    this.onTap,
  });

  final Post post;
  final Function()? onTap;

  bool get isTextTooLong => post.content.length > 255;
  TextStyle textStyle(BuildContext context) => Theme.of(context).textTheme.labelMedium!.copyWith(
        color: Theme.of(context).colorScheme.tertiary,
        fontWeight: FontWeight.normal,
      );

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return my?.hasBlocked(post.uid) != true
          ? GestureDetector(
              onTap: onTap,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: isTextTooLong ? post.content.substring(0, 140) : post.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (isTextTooLong)
                      TextSpan(
                        text: isTextTooLong ? ' ...read more' : '',
                        style: textStyle(context),
                      ),
                  ],
                ),
              ),
            )
          : Text(tr.blocked);
    }

    return ParsedReadMore(
      my?.hasBlocked(post.uid) != true ? post.content : 'Blocked',
      urlTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
          ),
      trimMode: TrimMode.line,
      trimLines: 3,
      delimiter: '  ...',
      delimiterStyle: Theme.of(context).textTheme.bodyMedium,
      style: Theme.of(context).textTheme.bodyMedium,
      onTapLink: (url) {
        toast(
          icon: const Icon(Icons.link),
          title: url,
          message: tr.askOpenLink,
          onTap: (p0) => launchUrl(Uri.parse(url)),
          hideCloseButton: true,
        );
      },
      trimCollapsedText: tr.readMore, // 'expand',
      trimExpandedText: tr.readLess, // 'compress',
      moreStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.normal,
          ),
      lessStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
            fontWeight: FontWeight.normal,
          ),
    );
  }
}
