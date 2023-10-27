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
          String nameString,
          String onName,
          Color Function(BuildContext context) onNameColor,
          String onNameString,
        })> colorUnits = [
      (
        name: 'primary',
        nameColor: (context) => Theme.of(context).colorScheme.primary,
        nameString: 'Theme.of(context).colorScheme.primary',
        onName: 'onPrimary',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameString: 'Theme.of(context).colorScheme.onPrimary'
      ),
      (
        name: 'secondary',
        nameColor: (context) => Theme.of(context).colorScheme.secondary,
        nameString: 'Theme.of(context).colorScheme.secondary',
        onName: 'onSecondary',
        onNameColor: (context) => Theme.of(context).colorScheme.onSecondary,
        onNameString: 'Theme.of(context).colorScheme.onSecondary'
      ),
      (
        name: 'tertiary',
        nameColor: (context) => Theme.of(context).colorScheme.tertiary,
        nameString: 'Theme.of(context).colorScheme.tertiary',
        onName: 'onTertiary',
        onNameColor: (context) => Theme.of(context).colorScheme.onTertiary,
        onNameString: 'Theme.of(context).colorScheme.onTertiary'
      ),
      (
        name: 'error',
        nameColor: (context) => Theme.of(context).colorScheme.error,
        nameString: 'Theme.of(context).colorScheme.error',
        onName: 'onError',
        onNameColor: (context) => Theme.of(context).colorScheme.onError,
        onNameString: 'Theme.of(context).colorScheme.onError'
      ),
      (
        name: 'background',
        nameColor: (context) => Theme.of(context).colorScheme.background,
        nameString: 'Theme.of(context).colorScheme.background',
        onName: 'onBackground',
        onNameColor: (context) => Theme.of(context).colorScheme.onBackground,
        onNameString: 'Theme.of(context).colorScheme.onBackground'
      ),
      (
        name: 'surface',
        nameColor: (context) => Theme.of(context).colorScheme.surface,
        nameString: 'Theme.of(context).colorScheme.surface',
        onName: 'onSurface',
        onNameColor: (context) => Theme.of(context).colorScheme.onSurface,
        onNameString: 'Theme.of(context).colorScheme.onSurface'
      ),
      (
        name: 'outline',
        nameColor: (context) => Theme.of(context).colorScheme.outline,
        nameString: 'Theme.of(context).colorScheme.outline',
        onName: 'No on outline',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameString: ''
      ),
      (
        name: 'shadow',
        nameColor: (context) => Theme.of(context).colorScheme.shadow,
        nameString: 'Theme.of(context).colorScheme.shadow',
        onName: 'No on shadow',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameString: ''
      ),
      (
        name: 'inverseSurface',
        nameColor: (context) => Theme.of(context).colorScheme.inverseSurface,
        nameString: 'Theme.of(context).colorScheme.inverseSurface',
        onName: 'onInverseSurface',
        onNameColor: (context) => Theme.of(context).colorScheme.onInverseSurface,
        onNameString: 'Theme.of(context).colorScheme.onInverseSurface'
      ),
      (
        name: 'inversePrimary',
        nameColor: (context) => Theme.of(context).colorScheme.inversePrimary,
        nameString: 'Theme.of(context).colorScheme.inversePrimary',
        onName: 'No on inversePrimary',
        onNameColor: (context) => Theme.of(context).colorScheme.primary,
        onNameString: ''
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Scheme'),
      ),
      // Generate a body of Column having 4 rows with flutter color scheme based on the current theme in Material Design version 3
      body: Column(
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
                  primaryName: colorUnit.name,
                  primaryColor: colorUnit.nameColor(context),
                  primaryString: colorUnit.nameString,
                  onPrimaryName: colorUnit.onName,
                  onPrimaryColor: colorUnit.onNameColor(context),
                  onPrimaryString: colorUnit.onNameString,
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
                      primaryName: colorUnit.name,
                      primaryColor: colorUnit.nameColor(context),
                      primaryString: colorUnit.nameString,
                      onPrimaryName: colorUnit.onName,
                      onPrimaryColor: colorUnit.onNameColor(context),
                      onPrimaryString: colorUnit.onNameString,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorUnit extends StatelessWidget {
  const ColorUnit({
    super.key,
    required this.primaryName,
    required this.primaryColor,
    required this.primaryString,
    required this.onPrimaryName,
    required this.onPrimaryColor,
    this.onPrimaryString = '',
  });

  final String primaryName;
  final Color primaryColor;
  final String primaryString;
  final String onPrimaryName;
  final Color onPrimaryColor;
  final String onPrimaryString;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        height: 80,
        color: primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryName,
              style: TextStyle(color: onPrimaryColor, fontSize: sizeSm),
            ),
            Center(
              child: Text(
                onPrimaryName,
                style: TextStyle(color: onPrimaryColor, fontSize: sizeSm),
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
              if (onPrimaryString.isNotEmpty)
                IconButton(
                  onPressed: () async => {
                    await Clipboard.setData(
                      ClipboardData(text: onPrimaryString),
                    )
                  },
                  icon: Icon(
                    Icons.edit,
                    color: onPrimaryColor,
                  ),
                ),
              IconButton(
                onPressed: () async => {
                  await Clipboard.setData(
                    ClipboardData(text: primaryString),
                  )
                },
                icon: Icon(
                  Icons.palette,
                  color: onPrimaryColor,
                ),
              )
            ],
          ))
    ]);
  }
}
