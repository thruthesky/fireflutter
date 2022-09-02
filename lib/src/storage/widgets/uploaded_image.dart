import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

/// UploadedImage
///
/// Use this widget to display images that are uploaded into firebase storage.
///
/// [url] is always the original image. Not thumbnail image.
///
/// When [useThumbnail] is set to true, it will look for thumbnail image, first.
///   - and when thumbnail image does not exist, then it will show original image
///     and if original image does not exists, then it will display error widget.
/// When [useThumbnail] is set to false, it will display original image.
///   - and if original image does not exists then it will display error widget.
///
/// When thumbnail does not exists, it may produce this error. See readme for details.
/// ```text
/// ════════ Exception caught by image resource service ════════════════════════════
/// The following HttpExceptionWithStatus was thrown resolving an image codec:
/// HttpException: Invalid statusCode: 403, uri = https://firebasestorage.googleapis.com/v0/b/wonderful-korea.appspot.com/o/test%2F6_200x200.webp?alt=media
/// ```

class UploadedImage extends StatelessWidget {
  UploadedImage({
    Key? key,
    required this.url,
    this.useThumbnail = true,
    this.errorWidget = const Icon(Icons.error),
    this.height,
    this.width,
    this.onTap,
    this.loader,
  }) : super(key: key);

  final String url;
  final bool useThumbnail;
  final Widget errorWidget;
  final Function()? onTap;
  final double? height;
  final double? width;
  final Widget? loader;

  @override
  Widget build(BuildContext context) {
    try {
      final uri = Uri.parse(url);
      if (uri.hasAbsolutePath == false) return errorWidget;
      if (uri.hasEmptyPath) return errorWidget;
    } on FormatException {
      return errorWidget;
    }
    final String _finalUrl = useThumbnail ? Storage.getThumbnailUrl(url) : url;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        height: height,
        width: width,
        imageUrl: _finalUrl,
        progressIndicatorBuilder: (c, s, p) =>
            loader ??
            Center(
              child: Container(
                width: 10,
                height: 10,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                ),
              ),
            ),
        errorWidget: (context, _recursiveUrl, error) {
          /// if it is original image and there is an error, then display error widget.
          if (useThumbnail == false) {
            return errorWidget;
          } else {
            /// If it failed on displaying thumbnail image, then try to display
            /// original image.
            return UploadedImage(
              url: url,
              useThumbnail: false,
              height: height,
              width: width,
              onTap: onTap,
              errorWidget: errorWidget,
            );
          }
        },
      ),
    );
  }
}
