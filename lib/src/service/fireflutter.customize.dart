import 'package:flutter/material.dart';

class FireFlutterCustomize {
  Future Function(
      {required BuildContext context,
      required String title,
      required String message})? alert;
  Future<bool?> Function(
      {required BuildContext context,
      required String title,
      required String message,
      List<Widget>? actions})? confirm;

  Future<String?> Function({
    required BuildContext context,
    required String title,
    String? hintText,
    String? subtitle,
    String? initialValue,
  })? prompt;

  FireFlutterCustomize({
    this.alert,
    this.confirm,
    this.prompt,
  });
}
