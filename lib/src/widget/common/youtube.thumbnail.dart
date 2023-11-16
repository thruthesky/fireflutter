import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeThumbnail extends StatelessWidget {
  const YouTubeThumbnail({
    super.key,
    required this.youtubeId,
    this.stackFit = StackFit.loose,
    this.boxFit,
    this.height,
    this.width,
    this.icon,
  });

  final String youtubeId;
  final StackFit stackFit;
  final BoxFit? boxFit;
  final double? height;
  final double? width;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    if (youtubeId.isEmpty) return const SizedBox.shrink();
    return Stack(
      fit: stackFit,
      children: [
        CachedNetworkImage(
          imageUrl: YoutubePlayer.getThumbnail(videoId: youtubeId),
          fit: boxFit,
          height: height,
          width: width,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: icon ??
                Icon(
                  Icons.play_circle,
                  size: 80,
                  color: Colors.white.withOpacity(.8),
                ),
          ),
        ),
      ],
    );
  }
}
