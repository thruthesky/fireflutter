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
    /// Adding the Ink well here so it doesn't need to set up outside
    /// and for UX purpose whatever image the user clicks it will be the first one to
    /// display on [PhotoViewerScreen]
    ///
    /// when the image is tap the `PhotoViewerScreen` would open and the first image
    /// that the user must see is the image that he/she tap. so by puting the gesture detector here
    /// and giving the proper index it will display the tap image by the user first.
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
                  height: 300,
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
