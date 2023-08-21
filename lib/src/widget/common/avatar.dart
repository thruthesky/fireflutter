import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar
///
/// [size] is the avatar size including the border width. Default is 24.
///
/// [borderWidth] is the border width. Default is 0.
/// If [borderWidth] is 1, then, the avatar size is 22. The border width is included in the size.
///
/// [borderColor] is the border color. Default is Colors.transparent.
///
/// [radius] is the border radius. Default is null.
///
/// [padding] is the padding of the avatar. Default is EdgeInsets.all(0). If border is given,
/// then, there will be padding between the border and the avatar.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.url,
    this.size = 24,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.radius,
    this.padding = const EdgeInsets.all(0),
  });

  final String url;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final double? radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius != null ? BorderRadius.circular(radius!) : null,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Padding(
        padding: padding,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Padding(
              padding: EdgeInsets.all(size / 4),
              child: const CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
