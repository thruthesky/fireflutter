import 'package:flutter/material.dart';

ThemeData defaultLightTheme({required BuildContext context}) {
  final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
  return ThemeData(
    // fontFamily: "Pretendard",
    colorScheme: colorScheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.secondary,
        backgroundColor: colorScheme.background,
        elevation: 0,
        side: BorderSide(
          color: colorScheme.secondary,
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.16),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Theme.of(context).colorScheme.onSurface.withAlpha(5),
      floatingLabelStyle: Theme.of(context).textTheme.labelLarge,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.16),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
    ),
    textTheme: const TextTheme(
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w300,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w300,
      ),
    ),
    useMaterial3: true,
  );
}
