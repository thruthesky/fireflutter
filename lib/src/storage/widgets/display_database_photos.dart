import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DisplayDatabasePhotos extends StatelessWidget {
  const DisplayDatabasePhotos({
    super.key,
    required this.urls,
    required this.path,
  });

  final List<String> urls;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Value(
      initialData: urls,
      path: path,
      builder: (v) {
        return DisplayPhotos(urls: List<String>.from(v ?? []));
      },
    );
  }
}
