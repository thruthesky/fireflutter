import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ImageListEdit extends StatefulWidget {
  const ImageListEdit({
    required this.files,
    // required this.onError,
    this.onDeleted,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  // final Function(dynamic) onError;
  final Function(String)? onDeleted;

  @override
  State<ImageListEdit> createState() => _ImageListEditState();
}

class _ImageListEditState extends State<ImageListEdit> {
  @override
  Widget build(BuildContext context) {
    if (widget.files.length == 0) return SizedBox.shrink();

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children: [
        for (String fileUrl in widget.files)
          EditUploadedImage(
            url: fileUrl,
            onDeleted: () {
              widget.files.remove(fileUrl);
              if (widget.onDeleted != null) widget.onDeleted!(fileUrl);
              setState(() {});
            },
          ),
      ],
    );
  }
}
