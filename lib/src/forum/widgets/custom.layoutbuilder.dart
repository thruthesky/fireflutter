import 'package:flutter/material.dart';

class CustomLayoutBuilder extends StatelessWidget {
  const CustomLayoutBuilder({super.key, required this.builder});
  final Widget Function(bool) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 600;
        return builder(isWideScreen);
      },
    );
  }
}
