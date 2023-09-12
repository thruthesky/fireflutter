import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTube extends StatefulWidget {
  const YouTube({
    super.key,
    required this.youtubeId,
    this.autoPlay = false,
    this.mute = false,
  });

  final String youtubeId;
  final bool autoPlay;
  final bool mute;

  @override
  State<YouTube> createState() => _YouTubeState();
}

class _YouTubeState extends State<YouTube> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.youtubeId.isEmpty) return;

    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: widget.mute,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.youtubeId.isEmpty) return const SizedBox.shrink();
    return _controller == null
        ? const SizedBox()
        : YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            progressColors: const ProgressBarColors(
              playedColor: Colors.blueAccent,
              handleColor: Colors.blueAccent,
            ),
            onReady: () {
              log('Player is ready.');
            },
          );
  }
}
