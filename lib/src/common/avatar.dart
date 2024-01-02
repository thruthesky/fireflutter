import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.photoUrl,
    this.size = 48,
    this.radius = 20,
  });

  final String photoUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        image: DecorationImage(
          image: CachedNetworkImageProvider(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
