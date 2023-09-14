import 'package:flutter/material.dart';

class TopDownGraident extends StatelessWidget {
  const TopDownGraident({
    super.key,
    this.height = 200,
    this.colors = const [
      Color(0x88222222),
      Colors.transparent,
    ],
  });

  final List<Color> colors;

  final double height;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            end: Alignment.bottomCenter,
            begin: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class BottomUpGraident extends StatelessWidget {
  const BottomUpGraident({
    super.key,
    this.height = 300,
    this.colors = const [
      Color(0x88222222),
      Colors.transparent,
    ],
  });

  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
