import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

/// FireFlutterService
class FireFlutterService {
  static FireFlutterService? _instance;
  static FireFlutterService get instance => _instance ??= FireFlutterService._();

  FireFlutterService._();

  /// BuildContext
  ///
  /// This is required to use the [toast] function in Fireflutter.
  BuildContext get context => _context!;
  BuildContext? _context;

  FireFlutterCustomize custom = FireFlutterCustomize();

  void init({
    required BuildContext context,
    FireFlutterCustomize? custom,
  }) {
    _context = context;
    if (custom != null) {
      this.custom = custom;
    }
  }

  void unInit() {
    _context = null;
  }
}
