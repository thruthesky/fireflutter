import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  ImageViewer(
    this.files, {
    this.initialIndex,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final int? initialIndex;

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _controller;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black45,
      body: Stack(
        children: [
          Container(
            width: double.maxFinite,
            child: PhotoViewGallery.builder(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              itemCount: widget.files.length,
              scrollPhysics: const ClampingScrollPhysics(),
              builder: (BuildContext context, int i) {
                return PhotoViewGalleryPageOptions(
                  minScale: .3,
                  imageProvider: NetworkImage(widget.files[i]),
                  initialScale: PhotoViewComputedScale.contained * 1,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.files[i]),
                );
              },
              loadingBuilder: (context, event) =>
                  Center(child: CircularProgressIndicator()),
              pageController: _controller,
              onPageChanged: (i) => setState(() => currentIndex = i),
            ),
          ),
          Container(
            child: IconButton(
              icon:
                  Icon(Icons.close_rounded, color: Colors.redAccent, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (currentIndex != 0)
            buildNavButton(Icons.arrow_left_rounded,
                callback: () => _controller.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    ),
                left: 18),
          if (currentIndex != widget.files.length - 1)
            buildNavButton(Icons.arrow_right_rounded,
                callback: () => _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    ),
                right: 18)
        ],
      ),
    );
  }

  Widget buildNavButton(
    IconData icon, {
    Function()? callback,
    double? right,
    double? left,
  }) {
    return Positioned(
      bottom: (MediaQuery.of(context).size.height / 2) - 28,
      right: right,
      left: left,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.7),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
            child: IconButton(
          icon: Icon(icon, color: Colors.black, size: 32),
          onPressed: callback,
        )),
      ),
    );
  }
}
