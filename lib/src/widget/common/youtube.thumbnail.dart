import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeThumbnail extends StatelessWidget {
  const YouTubeThumbnail({
    super.key,
    required this.youtubeId,
  });

  final String youtubeId;

  @override
  Widget build(BuildContext context) {
    if (youtubeId.isEmpty) return const SizedBox.shrink();
    return Stack(children: [
      CachedNetworkImage(
          imageUrl: YoutubePlayer.getThumbnail(videoId: youtubeId)),
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
