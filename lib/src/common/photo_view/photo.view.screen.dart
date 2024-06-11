import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewerScreen extends StatefulWidget {
  const PhotoViewerScreen({
    super.key,
    required this.urls,
    this.selectedIndex,
  });

  final List<String> urls;
  final int? selectedIndex;

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreen();
}

class _PhotoViewerScreen extends State<PhotoViewerScreen> {
  PageController controller = PageController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${(widget.selectedIndex ?? currentIndex) + 1}/${widget.urls.length}',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
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
        iconColor: const WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(
          Colors.black.withAlpha(100),
        ),
      ),
    );
  }
}
