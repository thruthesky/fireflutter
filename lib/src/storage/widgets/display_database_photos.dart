import 'dart:ui';

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
    print('path; $path');
    return Value(
      path: path,
      builder: (v) {
        return DisplayPhotos(urls: List<String>.from(v ?? []));
      },
    );
  }
}
