import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// README
class RecentPostCard extends StatelessWidget with ForumMixin {
  const RecentPostCard({super.key, this.category, this.hasPhoto = true});

  final String? category;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: postsQuery(category: category, hasPhoto: hasPhoto, limit: 1)
          .snapshots(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        }
        if (snapshot.hasError) {
          log(snapshot.error.toString());
          return Text(snapshot.error.toString());
        }
        if (snapshot.hasData == false || snapshot.data?.size == 0) {
          return Text(
              'Post not found for category: $category, hasPhoto: $hasPhoto');
        }

        final post = snapshot.data!.docs.first.data();
        return GestureDetector(
          onTap: () => {},
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: post.files.first,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        visualDensity:
                            const VisualDensity(horizontal: 4, vertical: -4),
                        label: const Text(
                          '자유게시판',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                        padding: const EdgeInsets.all(0),
                        backgroundColor: Colors.red.shade800,
                      ),
                      Text(
                        post.displayTitle,
                        // textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
