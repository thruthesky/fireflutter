import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CachedThumbnailFirstImage extends StatelessWidget {
  const CachedThumbnailFirstImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url.thumbnail,
      fit: BoxFit.cover,
      errorWidget: (context, errorUrl, error) {
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      },
      errorListener: (value) => debugPrint('Thumbnail not found: ${url.thumbnail}'),
    );
  }
}
