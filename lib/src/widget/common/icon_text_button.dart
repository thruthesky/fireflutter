import 'package:flutter/material.dart';

///
/// How to use
/*
IconTextButton(
  icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 22),
  iconBackgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(20),
  iconRadius: 20,
  iconPadding: const EdgeInsets.all(12),
  runSpacing: 4,
  label: "SHARE",
  labelStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
        fontSize: 10,
        color: Theme.of(context).colorScheme.secondary,
      ),
  onTap: () {},
),
*/
class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.icon,
    this.iconBackgroundColor,
    this.iconRadius = 20,
    this.iconPadding = const EdgeInsets.all(12),
    this.label,
    this.labelStyle,
    this.runSpacing = 4,
    required this.onTap,
  });

  final Widget icon;
  final Color? iconBackgroundColor;
  final double iconRadius;
  final EdgeInsets iconPadding;
  final String? label;
  final Function() onTap;
  final TextStyle? labelStyle;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(iconRadius),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(iconRadius),
              onTap: onTap,
              child: Container(
                padding: iconPadding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(iconRadius),
                  color: iconBackgroundColor ??
                      Theme.of(context).colorScheme.secondary.withAlpha(20),
                ),
                child: icon,
              ),
            ),
          ),
          SizedBox(height: runSpacing),
          if (label != null)
            Text(
              label!,
              style: labelStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
