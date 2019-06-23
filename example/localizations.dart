import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BaseLocalized {
  final String greetings = '';
  String welcome_back(String name) => '';
}

class ENLocalized extends BaseLocalized {
  final String greetings = 'Hello, world!';
  String welcome_back(String name) => 'Welcome back: $name';
}

class ESLocalized extends BaseLocalized {
  final String greetings = 'Hola, mundo!';
  String welcome_back(String name) => 'Bienvenido: $name';
}

class Localized {
  static BaseLocalized get;

  static List<Locale> locales = localized.keys.map((l) => Locale(l)).toList();

  static Map<String, BaseLocalized> localized = {
    'en': ENLocalized(),
    'es': ESLocalized()
  };

  static void load(Locale locale) {
    get = localized[locale.languageCode];
  }
}

class CustomLocalizationsDelegate extends LocalizationsDelegate {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => Localized.locales
      .map((l) => l.languageCode)
      .contains(locale.languageCode);

  @override
  Future load(Locale locale) {
    Localized.load(locale);
    return SynchronousFuture(Object());
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}