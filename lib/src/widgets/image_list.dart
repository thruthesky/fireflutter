import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class ImageList extends StatelessWidget {
  const ImageList({
    required this.files,
    this.onImageTap,
    this.noOfImagesToShow = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(int)? onImageTap;
  final int noOfImagesToShow;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    int imagesToShow = files.length < noOfImagesToShow ? files.length : noOfImagesToShow;

    if (files.length == 0) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: padding,
      child: files.length > 1
          ? GridView.count(
              padding: EdgeInsets.all(0),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              crossAxisCount: 3,
              children: [for (int i = 0; i < imagesToShow; i++) imageBuilder(i)],
            )
          : imageBuilder(0, false),
    );
  }

  Widget imageBuilder(int index, [bool useThumbnail = true]) {
    /// Display nothing by default.
    Widget _widget = SizedBox.shrink();

    /// Show image if:
    ///  - If file list is not empty;
    ///  - and, the current `index` is less than the `noOfImagesToShow`.
    if (files.isNotEmpty && index < noOfImagesToShow) {
      _widget = UploadedImage(
        url: files[index],
        onTap: () => onImageTap != null ? onImageTap!(index) : {},
        useThumbnail: useThumbnail,
      );
    }

    /// Add `more image` indicator when:
    ///  - If `index` is equal than the desired `noOfImagesToShow` (minus 1, since it `index` is based 0);
    ///  - and, length of files exceeds the desired `noOfImagesToShow`.
    if (index == (noOfImagesToShow - 1) && files.length > noOfImagesToShow) {
      _widget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onImageTap != null ? onImageTap!(index) : {},
        child: Stack(
          children: [
            Container(width: double.infinity, child: _widget),
            Container(
              color: Colors.black38,
              child: Center(
                child: Text(
                  '${files.length - (index + 1)}+ image',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _widget;
  }
}
