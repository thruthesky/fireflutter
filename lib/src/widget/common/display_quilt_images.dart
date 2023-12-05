import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayQuiltImages extends StatelessWidget {
  const DisplayQuiltImages({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox();
    if (urls.length == 1) {
      return CachedNetworkImage(
        imageUrl: urls[0],
        fit: BoxFit.contain,
      );
    }
    if (urls.length == 2) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: CachedNetworkImage(
              height: 200,
              imageUrl: urls[0],
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            child: CachedNetworkImage(
              height: 200,
              imageUrl: urls[1],
              fit: BoxFit.cover,
            ),
          ),
        ],
      );
    }

    if (urls.length == 3) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CachedNetworkImage(
                height: 200,
                imageUrl: urls[0],
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: urls[1],
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    flex: 1,
                    child: CachedNetworkImage(
                      width: double.infinity,
                      imageUrl: urls[2],
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: urls
          .asMap()
          .entries
          .map(
            (e) => CachedNetworkImage(
              imageUrl: e.value,
              fit: BoxFit.cover,
            ),
          )
          .toList(),
    );
  }
}
