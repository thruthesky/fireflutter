import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

extension FireFlutterStringExtension on String {
  int? tryInt() {
    return int.tryParse(this);
  }

  double? tryDouble() {
    return double.parse(this);
  }

  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Return value if the current string is empty.
  ///
  /// example
  /// ```dart
  /// ''.ifEmpty('This is empty!') // result: 'This is empty!'
  /// String? uid; uid?.ifEmpty('UID is empty!') // result: null
  ///
  /// ```
  String ifEmpty(String value) => isEmpty ? value : this;

  String upTo(int len) => length <= len ? this : substring(0, len);

  /// https://firebasestorage.googleapis.com/v0/b/grc-30ca7.appspot.com/o/users%2FNx85sXadVXT7KDSgD5SY132B4z42%2Fpexels-alejandro-navarrete-gonzalez-6959712.jpg?alt=media&token=bd30c81a-eb7d-4c17-ac58-9285b037fe51
  String get thumbnail {
    String u = this;
    u = u.replaceFirst(RegExp(".JPG", caseSensitive: false), "_200x200.webp");
    u = u.replaceFirst(RegExp(".JPEG", caseSensitive: false), "_200x200.webp");
    u = u.replaceFirst(RegExp(".PNG", caseSensitive: false), "_200x200.webp");

    return u;
  }

  /// Replace all the string of the map.
  String replace(Map<String, String> map) {
    String s = this;
    map.forEach((key, value) {
      s = s.replaceAll(key, value);
    });
    return s;
  }
}

extension Material3Palette on Color {
  Color tone(int tone) {
    assert(tone >= 0 && tone <= 100);
    final color = Hct.fromInt(value);
    final tonalPalette = TonalPalette.of(color.hue, color.chroma);
    return Color(tonalPalette.get(tone));
  }
}
