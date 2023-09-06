import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTube extends StatefulWidget {
  const YouTube({
    super.key,
    this.url,
    this.autoPlay = false,
    this.mute = false,
  });

  final String? url;
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

    if (widget.url == null || widget.url!.isEmpty) return;

    final id = YoutubePlayer.convertUrlToId(widget.url!);

    if (id == null) return;

    _controller = YoutubePlayerController(
      initialVideoId: id,
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
