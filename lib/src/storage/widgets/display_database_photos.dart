import 'package:fireship/fireship.dart';
import 'package:flutter/material.dart';

class DisplayDatabasePhotos extends StatelessWidget {
  const DisplayDatabasePhotos({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    return Value(
      path: path,
      builder: (v) => DisplayPhotos(urls: List<String>.from(v ?? [])),
    );
  }
}
