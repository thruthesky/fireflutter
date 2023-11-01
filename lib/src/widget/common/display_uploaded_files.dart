import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DisplayUploadedFiles extends StatelessWidget {
  const DisplayUploadedFiles({
    super.key,
    required this.otherUid,
    required this.urls,
  });

  final String otherUid;
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox();
    // for blocked users.
    if (my?.hasBlocked(otherUid) == true) {
      return const SizedBox();
    }

    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: urls
            .asMap()
            .entries
            .map(
              (e) => GestureDetector(
                onTap: () => StorageService.instance.showUploads(
                  context,
                  urls,
                  index: e.key,
                ),
                child: CachedNetworkImage(
                  imageUrl: e.value.thumbnail,
                  fit: BoxFit.contain,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
