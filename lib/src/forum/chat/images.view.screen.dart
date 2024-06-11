import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewScreen extends StatefulWidget {
  const ImageViewScreen({
    super.key,
    required this.urls,
    this.selectedIndex,
  });

  final List<String> urls;
  final int? selectedIndex;

  @override
  State<ImageViewScreen> createState() => _ImageViewScreen();
}

class _ImageViewScreen extends State<ImageViewScreen> {
  PageController controller = PageController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${(widget.selectedIndex ?? currentIndex) + 1}/${widget.urls.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: controller,
            itemCount: widget.urls.length,
            builder: (_, index) => PhotoViewGalleryPageOptions(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: CachedNetworkImageProvider(widget.urls[index]),
              heroAttributes: PhotoViewHeroAttributes(tag: widget.urls[index]),
            ),
            backgroundDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            onPageChanged: (index) {
              currentIndex = index;
              setState(() {});
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  iconButton(
                    context,
                    onPressed: () => controller
                        .previousPage(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear)
                        .toString(),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  iconButton(
                    context,
                    onPressed: () => controller
                        .nextPage(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.linear)
                        .toString(),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  iconButton(contex, {required Icon icon, required Function() onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      style: ButtonStyle(
        iconColor:
            WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surface.withAlpha(150),
        ),
      ),
    );
  }
}
