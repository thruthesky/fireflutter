import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
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

    ///
    /// Adding the Gesture detector here so it doesn't need to set up outside
    /// and for UX purpose whatever image the user clicks it will be the first one to
    /// display on [PhotoViewerScreen]
    ///
    final List<Widget> children = urls
        .asMap()
        .map(
          (index, url) => MapEntry(
            index,
            InkWell(
              onTap: () => showGeneralDialog(
                context: context,
                pageBuilder: (_, __, ___) => PhotoViewerScreen(
                  urls: urls,
                  selectedIndex: index,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
          ),
        )
        .values
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
