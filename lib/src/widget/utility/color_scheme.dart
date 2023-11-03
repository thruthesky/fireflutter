import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorSchemeScreen extends StatelessWidget {
  const ColorSchemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<
        ({
          String name,
          Color Function(BuildContext context) nameColor,
          String nameColorCode,
          String onName,
          Color Function(BuildContext context) onNameColor,
          String onNameColorCode,
        })> colorUnits = [
      (
        name: 'primary',
        nameColor: (context) => Theme.of(context).colorScheme.primary,
        nameColorCode: 'Theme.of(context).colorScheme.primary',
        onName: 'onPrimary',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: 'Theme.of(context).colorScheme.onPrimary'
      ),
      (
        name: 'secondary',
        nameColor: (context) => Theme.of(context).colorScheme.secondary,
        nameColorCode: 'Theme.of(context).colorScheme.secondary',
        onName: 'onSecondary',
        onNameColor: (context) => Theme.of(context).colorScheme.onSecondary,
        onNameColorCode: 'Theme.of(context).colorScheme.onSecondary'
      ),
      (
        name: 'tertiary',
        nameColor: (context) => Theme.of(context).colorScheme.tertiary,
        nameColorCode: 'Theme.of(context).colorScheme.tertiary',
        onName: 'onTertiary',
        onNameColor: (context) => Theme.of(context).colorScheme.onTertiary,
        onNameColorCode: 'Theme.of(context).colorScheme.onTertiary'
      ),
      (
        name: 'error',
        nameColor: (context) => Theme.of(context).colorScheme.error,
        nameColorCode: 'Theme.of(context).colorScheme.error',
        onName: 'onError',
        onNameColor: (context) => Theme.of(context).colorScheme.onError,
        onNameColorCode: 'Theme.of(context).colorScheme.onError'
      ),
      (
        name: 'background',
        nameColor: (context) => Theme.of(context).colorScheme.background,
        nameColorCode: 'Theme.of(context).colorScheme.background',
        onName: 'onBackground',
        onNameColor: (context) => Theme.of(context).colorScheme.onBackground,
        onNameColorCode: 'Theme.of(context).colorScheme.onBackground'
      ),
      (
        name: 'surface',
        nameColor: (context) => Theme.of(context).colorScheme.surface,
        nameColorCode: 'Theme.of(context).colorScheme.surface',
        onName: 'onSurface',
        onNameColor: (context) => Theme.of(context).colorScheme.onSurface,
        onNameColorCode: 'Theme.of(context).colorScheme.onSurface'
      ),
      (
        name: 'outline',
        nameColor: (context) => Theme.of(context).colorScheme.outline,
        nameColorCode: 'Theme.of(context).colorScheme.outline',
        onName: 'No on outline',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: ''
      ),
      (
        name: 'shadow',
        nameColor: (context) => Theme.of(context).colorScheme.shadow,
        nameColorCode: 'Theme.of(context).colorScheme.shadow',
        onName: 'No on shadow',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: ''
      ),
      (
        name: 'inverseSurface',
        nameColor: (context) => Theme.of(context).colorScheme.inverseSurface,
        nameColorCode: 'Theme.of(context).colorScheme.inverseSurface',
        onName: 'onInverseSurface',
        onNameColor: (context) => Theme.of(context).colorScheme.onInverseSurface,
        onNameColorCode: 'Theme.of(context).colorScheme.onInverseSurface'
      ),
      (
        name: 'inversePrimary',
        nameColor: (context) => Theme.of(context).colorScheme.inversePrimary,
        nameColorCode: 'Theme.of(context).colorScheme.inversePrimary',
        onName: 'No on inversePrimary',
        onNameColor: (context) => Theme.of(context).colorScheme.primary,
        onNameColorCode: ''
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Scheme'),
      ),
      // Generate a body of Column having 4 rows with flutter color scheme based on the current theme in Material Design version 3
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
                'The background of the square box is the main color, and the color of the text is actually the color to be seen on that color'),
            const Text('Light Mode'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              children: [
                for (final colorUnit in colorUnits)
                  ColorUnit(
                    keyColorName: colorUnit.name,
                    keyColor: colorUnit.nameColor(context),
                    keyColorCode: colorUnit.nameColorCode,
                    onKeyColorName: colorUnit.onName,
                    onKeyColor: colorUnit.onNameColor(context),
                    onKeyColorCode: colorUnit.onNameColorCode,
                  ),
              ],
            ),
            const Text('Dark Mode'),
            Theme(
              data: ThemeData.dark(useMaterial3: true),
              child: Builder(
                builder: (context) => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  children: [
                    for (final colorUnit in colorUnits)
                      ColorUnit(
                        keyColorName: colorUnit.name,
                        keyColor: colorUnit.nameColor(context),
                        keyColorCode: colorUnit.nameColorCode,
                        onKeyColorName: colorUnit.onName,
                        onKeyColor: colorUnit.onNameColor(context),
                        onKeyColorCode: colorUnit.onNameColorCode,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorUnit extends StatelessWidget {
  const ColorUnit({
    super.key,
    required this.keyColorName,
    required this.keyColor,
    required this.keyColorCode,
    required this.onKeyColorName,
    required this.onKeyColor,
    this.onKeyColorCode = '',
  });

  final String keyColorName;
  final Color keyColor;
  final String keyColorCode;
  final String onKeyColorName;
  final Color onKeyColor;
  final String onKeyColorCode;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: 80,
        color: keyColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              keyColorName,
              style: TextStyle(color: onKeyColor, fontSize: sizeSm),
            ),
            Center(
              child: Text(
                onKeyColorName,
                style: TextStyle(color: onKeyColor, fontSize: sizeSm),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
      Positioned(
          right: 0,
          top: 0,
          child: Row(
            children: [
              if (onKeyColorCode.isNotEmpty)
                IconButton(
                  onPressed: () async => {
                    await Clipboard.setData(
                      ClipboardData(text: onKeyColorCode),
                    )
                  },
                  icon: Icon(
                    Icons.edit,
                    color: onKeyColor,
                  ),
                ),
              IconButton(
                onPressed: () async => {
                  await Clipboard.setData(
                    ClipboardData(text: keyColorCode),
                  )
                },
                icon: Icon(
                  Icons.palette,
                  color: onKeyColor,
                ),
              )
            ],
          ))
    ]);
  }
}
