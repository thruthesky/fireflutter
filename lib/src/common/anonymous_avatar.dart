import 'package:flutter/material.dart';

class AnonymousAvatar extends StatelessWidget {
  const AnonymousAvatar({
    super.key,
    this.size = 48,
    this.radius = 20,
    this.text,
  });

  final double size;
  final double radius;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Theme.of(context).colorScheme.secondary.withAlpha(50),
      ),
      child: text == null
          ? Icon(
              Icons.person,
              size: size * 0.62,
            )
          : Center(
              child: Text(
                text!,
                style: TextStyle(
                  fontSize: size * 0.62,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
    );
  }
}
