import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';

/// Returns a list of preferred languages in two letter format using [devicelocale] package.
Future<dynamic> get preferredLanguages async {
  final locales = await Devicelocale.preferredLanguages;
  return locales?.map((e) => e.split('-').first).toList();
}

/// Returns the current locale in two letter format using [deviceLocale] package.
Future<String?> get currentLocale async {
  final locale = await Devicelocale.currentLocale;
  if (locale == null) return null;
  return locale.split('-').first;
}

/// Returns the language code of the current locale using the current FlutterView from the context
/// via View.of(context)
String getLanguageCode(BuildContext context) {
  return View.of(context).platformDispatcher.locale.languageCode;
}
