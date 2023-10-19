import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayUploadedFile extends StatelessWidget {
  const DisplayUploadedFile({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(imageUrl: url);
  }
}
