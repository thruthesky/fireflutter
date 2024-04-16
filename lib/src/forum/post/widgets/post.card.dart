import 'package:cached_network_image/cached_network_image.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.displayAvatar = false,
    this.displaySubtitle = false,
  });

  final Post post;
  final bool displayAvatar;
  final bool displaySubtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ForumService.instance.showPostViewScreen(
            context: context,
            post: post,
          );
        },
        child: Container(
          child: Stack(
            children: [
              if (post.urls.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: post.urls.first,
                    fit: BoxFit.cover,
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: displaySubtitle ? 100 : 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayAvatar)
                        UserAvatar(
                          cacheId: 'app',
                          uid: post.uid,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.4,
                          ),
                        ),
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displaySubtitle)
                        Text(
                          post.content.cut(128),
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Colors.white,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
