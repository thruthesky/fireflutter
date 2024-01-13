import 'package:flutter/material.dart';

/// Display photos that are uploaded to Firebase Storage.
///
/// Display one photo per line in a column.
class DisplayPhotos extends StatelessWidget {
  const DisplayPhotos({super.key, required this.urls});

  final List<String> urls;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: urls.map((url) {
        return Image.network(
          url,
          fit: BoxFit.cover,
        );
      }).toList(),
    );
  }
}
