import 'package:flutter/material.dart';

/// FireFlutterService
class FireFlutterService {
  static FireFlutterService? _instance;
  static FireFlutterService get instance =>
      _instance ??= FireFlutterService._();

  FireFlutterService._();

  /// BuildContext
  ///
  /// This is required to use the [toast] function in Fireflutter.
  BuildContext get context => _context!;
  BuildContext? _context;

  void init({
    required BuildContext context,
  }) {
    _context = context;
  }

  void unInit() {
    _context = null;
  }
}
