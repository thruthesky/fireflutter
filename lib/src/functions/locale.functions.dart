import 'package:devicelocale/devicelocale.dart';

/// Returns a list of preferred languages in two letter format.
Future<dynamic> get preferredLanguages async {
  final locales = await Devicelocale.preferredLanguages;
  return locales?.map((e) => e.split('-').first).toList();
}

/// Returns the current locale in two letter format.
Future<String?> get currentLocale async {
  final locale = await Devicelocale.currentLocale;
  if (locale == null) return null;
  return locale.split('-').first;
}
