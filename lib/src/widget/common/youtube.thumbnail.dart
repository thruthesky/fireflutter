import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeThumbnail extends StatelessWidget {
  const YouTubeThumbnail({
    super.key,
    this.youtubeId,
    this.youtubeUrl,
  });

  final String? youtubeId;
  final String? youtubeUrl;

  @override
  Widget build(BuildContext context) {
    final id = youtubeId ?? YoutubePlayer.convertUrlToId(youtubeUrl!);
    if ((id ?? '').isEmpty) return const SizedBox.shrink();
    return Stack(children: [
      CachedNetworkImage(imageUrl: YoutubePlayer.getThumbnail(videoId: id!)),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Center(
          child: Icon(
            Icons.play_circle,
            size: 100,
            color: Colors.white.withOpacity(.8),
          ),
        ),
      ),
    ]);
  }
}
