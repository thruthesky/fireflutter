import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Display photos that are uploaded to Firebase Storage.
///
/// Display one photo per line in a column.
class DisplayPhotos extends StatelessWidget {
  const DisplayPhotos({super.key, required this.urls});

  final List<String> urls;
  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    final List<Widget> children = urls
        .map(
          (url) => SizedBox(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                // added sizes
                width: double.infinity,
                height: 200,
              ),
            ),
          ),
        )
        .toList()
        .fold(
      [],
      (prev, curr) => prev
        ..add(curr)
        ..add(const SizedBox(height: 8)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.sublist(0, children.length - 1),
    );
  }
}
