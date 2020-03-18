import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import './localizations.dart';

class LocalizationManager {
  static Locale current;
  static List<String> supportedLanguageCodes = ['en', 'es'];
  static List<Locale> get locales =>
      supportedLanguageCodes.map((String l) => Locale(l)).toList();

  static bool isSupported(Locale locale) =>
      locales.map((Locale l) => l.languageCode).contains(locale.languageCode);

  static void load(Locale locale) {
    current = locale;
    Localized.get = localizedForLocal(locale);
  }

  static BaseLocalized localizedForLocal(Locale locale) {
    switch (locale.languageCode) {
     case 'en': return ENLocalized();
     case 'es': return ESLocalized();
     default: return ENLocalized();
    }
  }
}

class CustomLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => LocalizationManager.isSupported(locale);

  @override
  Future<dynamic> load(Locale locale) {
    LocalizationManager.load(locale);
    return SynchronousFuture<dynamic>(Object());
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}
