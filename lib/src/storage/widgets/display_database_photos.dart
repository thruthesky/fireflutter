import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// Display photos that are uploaded to Firebase Storage.
///
/// [initialData] is a list of URLs of the photos to be displayed before getting
/// the photo urls(data) from the database.
class DisplayDatabasePhotos extends StatelessWidget {
  const DisplayDatabasePhotos({
    super.key,
    required this.initialData,
    required this.ref,
  });

  final List<String> initialData;
  final DatabaseReference ref;

  @override
  Widget build(BuildContext context) {
    return Value(
      initialData: initialData,
      ref: ref,
      builder: (v) {
        return DisplayPhotos(urls: List<String>.from(v ?? []));
      },
    );
  }
}
