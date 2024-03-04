import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class DisplayDatabasePhotos extends StatelessWidget {
  const DisplayDatabasePhotos({
    super.key,
    required this.urls,
    required this.ref,
  });

  final List<String> urls;
  final DatabaseReference ref;

  @override
  Widget build(BuildContext context) {
    return Value(
      initialData: urls,
      ref: ref,
      builder: (v) {
        return DisplayPhotos(urls: List<String>.from(v ?? []));
      },
    );
  }
}
