import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar
///
/// [size] is the avatar size including the border width. Default is 24.
///
/// [borderWidth] is the border width. Default is 1.
/// If [borderWidth] is 1, then, the avatar size is 22. The border width is included in the size.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.url,
    this.size = 24,
    this.borderWidth = 1,
    this.borderColor = Colors.grey,
    this.radius,
  });

  final String url;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius != null ? BorderRadius.circular(radius!) : null,
        color: borderColor,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
