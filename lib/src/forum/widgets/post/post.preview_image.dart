import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class PostPreviewImage extends StatelessWidget {
  const PostPreviewImage({required this.url, this.size = 60, Key? key})
      : super(key: key);

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: UploadedImage(url: url, width: size, height: size),
    );
  }
}
