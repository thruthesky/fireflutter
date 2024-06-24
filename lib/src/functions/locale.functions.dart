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

/// Returns the current locale in "[langaugeCode]_[countryCode]" format using [Intl] package.
/// Example: "en_US", "ko_KR"
String getIntlCurrentLocale() {
  return Intl.getCurrentLocale();
}

/// Initialize the default Intl locale  base FlutterView from the context
/// Or directly passing a locale string.
///
/// Usage
/// ```dart
/// class _AppState extends State<App> {
///  bool flagInitLocalization = false;
///
///  @override
///  Widget build(BuildContext context) {
///    if (flagInitLocalization == false) {
///      flagInitLocalization = true;
///      initIntlDefaultLocale(context);
///    }
///    ....
///  }
/// ```
/// If this is properly set, the display of DateFormat method will automatically update the display to correspanding locale.
///
/// Example:
/// DateFormat.yMMMEd().format(DateTime.now());
///
/// The code above should automatically adjust base to the current locale.

///
initIntlDefaultLocale(BuildContext context, {String? locale}) async {
  locale ??= getDefaultLocale(context);
  print('initIntlDefaultLocale: $locale');
  Intl.defaultLocale = locale;
}

String getDefaultLocale(BuildContext context) =>
    View.of(context).platformDispatcher.locale.toString();
