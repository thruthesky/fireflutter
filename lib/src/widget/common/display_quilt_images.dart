import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayQuiltImages extends StatelessWidget {
  const DisplayQuiltImages({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox();
    if (urls.length == 1) return _expandedCachedNetworkImage(urls[0], height: 400);
    if (urls.length == 2) {
      return Row(
        children: [
          _expandedCachedNetworkImage(urls[0], height: 200),
          const SizedBox(width: 2),
          _expandedCachedNetworkImage(urls[1], height: 200),
        ],
      );
    }

    if (urls.length == 3) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            _expandedCachedNetworkImage(urls[0], height: 200),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  _expandedCachedNetworkImage(urls[1], width: double.infinity),
                  const SizedBox(height: 2),
                  _expandedCachedNetworkImage(urls[2], width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (urls.length == 4) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: urls.asMap().entries.map((e) => CachedNetworkImage(imageUrl: e.value, fit: BoxFit.cover)).toList(),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: urls.asMap().entries.map((e) => CachedNetworkImage(imageUrl: e.value, fit: BoxFit.cover)).toList(),
    );
  }

  _expandedCachedNetworkImage(String url, {double? height, double? width}) {
    return Expanded(
      child: CachedNetworkImage(
        height: height,
        width: width,
        imageUrl: url,
        fit: BoxFit.cover,
      ),
    );
  }
}
