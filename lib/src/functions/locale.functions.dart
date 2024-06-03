import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
/// Example: "en", "ko"
String getLanguageCode(BuildContext context) {
  return View.of(context).platformDispatcher.locale.languageCode;
}

Locale getDeviceCurrentLocale(BuildContext context) {
  return View.of(context).platformDispatcher.locale;
}

/// Returns the current locale in "[langaugeCode]_[countryCode]" format using [Intl] package.
/// Example: "en_US", "ko_KR"
String getIntlCurrentLocale() {
  return Intl.getCurrentLocale();
}

/// By default it set the default Intl.defaultLocale from the current device locale using the Flutterview from the context
///
/// You can pass locale as string to set the default Intl.defaultLocale
/// Example:  setIntlDefaultLocale(context, locale: "en_US") or setIntlDefaultLocale(context, locale: "ko_KR")
///
/// This will automatically adjust the locale display on date format
///
setIntlDefaultLocale(BuildContext context, {String? locale}) {
  locale ??= getDeviceCurrentLocale(context).toString();
  Intl.defaultLocale = locale;
  // Intl.systemLocale = locale;
}
