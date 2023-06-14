import 'package:flutter/material.dart';

class PhotoFrame extends StatelessWidget {
  const PhotoFrame({
    super.key,
    required this.imagePath,
  });
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Image(
              image: NetworkImage(imagePath),
            ),
            //  child: CachedNetworkImage(
            //   image: NetworkImage(imagePath),
            // ),
          ),
        ),
      ),
    );
  }
}
