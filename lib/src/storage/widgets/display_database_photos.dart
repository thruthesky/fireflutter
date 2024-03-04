import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DisplayDatabasePhotos extends StatelessWidget {
  const DisplayDatabasePhotos({
    super.key,
    required this.urls,
    this.path,
    this.ref,
  }) : assert(path != null || ref != null);

  final List<String> urls;
  final String? path;
  final DatabaseReference? ref;

  @override
  Widget build(BuildContext context) {
    return Value(
      initialData: urls,
      path: path,
      ref: ref,
      builder: (v) {
        return DisplayPhotos(urls: List<String>.from(v ?? []));
      },
    );
  }
}
