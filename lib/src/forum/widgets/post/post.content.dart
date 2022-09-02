import 'package:flutter/foundation.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class PostContent extends StatelessWidget {
  const PostContent(
    this.post, {
    this.withImage = true,
    this.onImageTapped,
    this.padding,
    Key? key,
  }) : super(key: key);

  final Post post;
  final bool withImage;
  final Function(String)? onImageTapped;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (post.content.isEmpty) return SizedBox.shrink();
    return Column(
      children: [
        Container(
          padding: padding,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white),
          child: () {
            /// Youtube link 가 있다면, (HTML 이 있든 없든)
            // if (hasYoutubeLink(post.content)) {
            //   String content = convertYoutubeLinkToEmbedHTML(post.content);
            //   return HtmlContent(content);
            // } else if (post.html)
            if (post.isHtmlContent)
              return Html(
                data: post.displayContent,
                onImageTap: (url, renderContext, attributes, element) {
                  if (onImageTapped != null) onImageTapped!(url ?? '');
                },
                customRenders: {
                  networkSourceMatcher(): networkImageRender(loadingWidget: () {
                    // if (Platform.isIOS || Platform.isMacOS) {
                    if (defaultTargetPlatform == TargetPlatform.iOS ||
                        defaultTargetPlatform == TargetPlatform.macOS) {
                      return SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: Center(child: CircularProgressIndicator.adaptive()));
                    }
                    return CircularProgressIndicator();
                  }),
                },
                style: {
                  "body": Style(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                  ),

                  /// 웹에서 Tiny MCE 편집기로 글을 작성 할 때,
                  /// P 태그에 style="margin-top: 0; margin-bottom: 8px;" 와 같이 적용되는데,
                  /// flutter_html 에서 잘 적용이 안되어서, 여기서 따로 적용해 준다.
                  "p": Style(margin: EdgeInsets.only(top: 16, bottom: 16)),
                  "img": Style(padding: EdgeInsets.only(top: 4, bottom: 4)),
                },
                onLinkTap: (url, renderContext, attr, element) => openLink(url),
              );
            else
              return SelectableLinkify(
                text: post.displayContent,
                style: TextStyle(height: 1.6),
                onOpen: (link) => openLink(link.url),
              );
          }(),
        ),
      ],
    );
  }

  openLink(String? url) async {
    if (url == null) return;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
