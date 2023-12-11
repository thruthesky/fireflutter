import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
// import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DisplayQuiltImages extends StatelessWidget {
  const DisplayQuiltImages({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox();
    if (urls.length == 1) {
      // return CachedNetworkImage(
      //   imageUrl: urls[0],
      //   fit: BoxFit.contain,
      // );
      return DisplayMedia(url: urls[0]);
    }
    if (urls.length == 2) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            // todo
            // git task https://github.com/users/thruthesky/projects/9/views/21?pane=issue&itemId=47196607
            //
            // child: CachedNetworkImage(
            //   height: 200,
            //   imageUrl: urls[0],
            //   fit: BoxFit.cover,
            // ),
            child: DisplayMedia(
              url: urls[0],
              height: 200,
            ),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 1,
            // child: CachedNetworkImage(
            //   height: 200,
            //   imageUrl: urls[1],
            //   fit: BoxFit.cover,
            // ),
            child: DisplayMedia(url: urls[1], height: 200),
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
              // child: CachedNetworkImage(
              //   height: 200,
              //   imageUrl: urls[0],
              //   fit: BoxFit.cover,
              // ),
              child: DisplayMedia(url: urls[1], height: 200),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    // child: CachedNetworkImage(
                    //   width: double.infinity,
                    //   imageUrl: urls[1],
                    //   fit: BoxFit.cover,
                    // ),
                    child: DisplayMedia(
                      url: urls[1],
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    flex: 1,
                    // child: CachedNetworkImage(
                    //   width: double.infinity,
                    //   imageUrl: urls[2],
                    //   fit: BoxFit.cover,
                    // ),
                    child: DisplayMedia(
                      url: urls[2],
                      width: double.infinity,
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
