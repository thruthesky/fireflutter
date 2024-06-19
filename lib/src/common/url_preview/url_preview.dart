import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// [UrlPreview] is a widget that shows a preview of a URL.
///
/// [text] is the text that contains the URL. The first URL in the text is
/// used to generate the preview.
///
/// [descriptionLength] is the length of the description.
///
/// [builder] is a builder function that takes the preview widget as [child]
/// parameter. You can customize the preview widget by using the [builder].
///
class UrlPreview extends StatelessWidget {
  const UrlPreview({
    super.key,
    required this.previewUrl,
    this.title,
    this.description,
    this.imageUrl,
  });

  final String previewUrl;
  final String? title;
  final String? description;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (previewUrl.isNullOrEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        if (await canLaunchUrlString(previewUrl)) {
          await launchUrlString(previewUrl);
        } else {
          throw 'Could not launch $previewUrl';
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!imageUrl.isNullOrEmpty) ...[
              CachedNetworkImage(
                imageUrl: imageUrl!,
                // Don't show
                errorWidget: (context, url, error) {
                  dog("Not showing an image preview because there's a problem with the url: $imageUrl");
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
            ],
            if (!title.isNullOrEmpty) ...[
              Text(
                title!,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!description.isNullOrEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description!.length > 100
                    ? '${description!.substring(0, 90)}...'
                    : description!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
