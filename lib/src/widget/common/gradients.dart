import 'package:flutter/material.dart';

class TopDownGraident extends StatelessWidget {
  const TopDownGraident({
    super.key,
    this.height = 200,
  });

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
            colors: [Theme.of(context).colorScheme.secondary.withAlpha(120), Colors.transparent],
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
  });

  final double height;

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
            colors: [Theme.of(context).colorScheme.secondary.withAlpha(150), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}
