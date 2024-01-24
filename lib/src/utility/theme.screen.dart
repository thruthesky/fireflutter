import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme Screen
///
/// 현재 앱의 테마 색상 및 폰트 등의 표현해서, 눈으로 쉽게 확인 할 수 있도록 한다.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

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
        name: 'primaryContainer',
        nameColor: (context) => Theme.of(context).colorScheme.primaryContainer,
        nameColorCode: 'Theme.of(context).colorScheme.primaryContainer',
        onName: 'onPrimaryContainer',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onPrimaryContainer,
        onNameColorCode: 'Theme.of(context).colorScheme.primaryContainer'
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
        name: 'secondaryContainer',
        nameColor: (context) =>
            Theme.of(context).colorScheme.secondaryContainer,
        nameColorCode: 'Theme.of(context).colorScheme.secondaryContainer',
        onName: 'onSecondaryContainer',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onSecondaryContainer,
        onNameColorCode: 'Theme.of(context).colorScheme.onSecondaryContainer'
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
        name: 'tertiaryContainer',
        nameColor: (context) => Theme.of(context).colorScheme.tertiaryContainer,
        nameColorCode: 'Theme.of(context).colorScheme.tertiaryContainer',
        onName: 'onTertiaryContainer',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onTertiaryContainer,
        onNameColorCode: 'Theme.of(context).colorScheme.onTertiaryContainer'
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
        name: 'errorContainer',
        nameColor: (context) => Theme.of(context).colorScheme.errorContainer,
        nameColorCode: 'Theme.of(context).colorScheme.errorContainer',
        onName: 'onErrorContainer',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onErrorContainer,
        onNameColorCode: 'Theme.of(context).colorScheme.onErrorContainer'
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
        name: 'surfaceVariant',
        nameColor: (context) => Theme.of(context).colorScheme.surfaceVariant,
        nameColorCode: 'Theme.of(context).colorScheme.surfaceVariant',
        onName: 'onSurfaceVariant',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onSurfaceVariant,
        onNameColorCode: 'Theme.of(context).colorScheme.onSurfaceVariant'
      ),
      (
        name: 'inverseSurface',
        nameColor: (context) => Theme.of(context).colorScheme.inverseSurface,
        nameColorCode: 'Theme.of(context).colorScheme.inverseSurface',
        onName: 'onInverseSurface',
        onNameColor: (context) =>
            Theme.of(context).colorScheme.onInverseSurface,
        onNameColorCode: 'Theme.of(context).colorScheme.onInverseSurface'
      ),
      (
        name: 'surfaceTint',
        nameColor: (context) => Theme.of(context).colorScheme.surfaceTint,
        nameColorCode: 'Theme.of(context).colorScheme.surfaceTint',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: 'Theme.of(context).colorScheme.onInverseSurface'
      ),
      (
        name: 'inversePrimary',
        nameColor: (context) => Theme.of(context).colorScheme.inversePrimary,
        nameColorCode: 'Theme.of(context).colorScheme.inversePrimary',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.primary,
        onNameColorCode: ''
      ),
      (
        name: 'outline',
        nameColor: (context) => Theme.of(context).colorScheme.outline,
        nameColorCode: 'Theme.of(context).colorScheme.outline',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: ''
      ),
      (
        name: 'outlineVariant',
        nameColor: (context) => Theme.of(context).colorScheme.outlineVariant,
        nameColorCode: 'Theme.of(context).colorScheme.outlineVariant',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: ''
      ),
      (
        name: 'shadow',
        nameColor: (context) => Theme.of(context).colorScheme.shadow,
        nameColorCode: 'Theme.of(context).colorScheme.shadow',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
        onNameColorCode: ''
      ),
      (
        name: 'scrim',
        nameColor: (context) => Theme.of(context).colorScheme.scrim,
        nameColorCode: 'Theme.of(context).colorScheme.scrim',
        onName: '',
        onNameColor: (context) => Theme.of(context).colorScheme.onPrimary,
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
            const Text('Theme Fonts'),
            Text('Display Large',
                style: Theme.of(context).textTheme.displayLarge),
            Text('Display Medium',
                style: Theme.of(context).textTheme.displayMedium),
            Text('Display Small',
                style: Theme.of(context).textTheme.displaySmall),
            Text('Headline Large',
                style: Theme.of(context).textTheme.headlineLarge),
            Text('Headline Medium',
                style: Theme.of(context).textTheme.headlineMedium),
            Text('Headline Small',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
            Text('Title Medium',
                style: Theme.of(context).textTheme.titleMedium),
            Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
            Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
            Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
            Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
            Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
            Text('Label Medium',
                style: Theme.of(context).textTheme.labelMedium),
            Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
            const Divider(
              height: 32,
            ),
            const Text('Theme Color'),
            const Text(
                'The background of the square box is the main color, and the color of the text is actually the color to be seen on that color'),
            const Text('Light Mode'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
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
                  crossAxisCount: 4,
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
        height: 100,
        color: keyColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              keyColorName,
              style: TextStyle(color: onKeyColor, fontSize: 12),
            ),
            Center(
              child: Text(
                onKeyColorName,
                style: TextStyle(color: onKeyColor, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 16),
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
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
