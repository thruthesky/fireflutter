import 'package:flutter/material.dart';

class FireFlutterService {
  static FireFlutterService? _instance;
  static FireFlutterService get instance =>
      _instance ??= FireFlutterService._();

  FireFlutterService._();

  late BuildContext context;

  void init({
    required BuildContext context,
  }) {
    this.context = context;
  }
}
