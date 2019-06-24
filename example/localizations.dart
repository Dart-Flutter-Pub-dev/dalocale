import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class BaseLocalized {

  String get greetings;

  String welcomeBack(Object name);
}

class ENLocalized extends BaseLocalized {

  @override
  String get greetings => 'Hello, world!';

  @override
  String welcomeBack(Object name) => 'Welcome back: ${name.toString()}';
}

class ESLocalized extends BaseLocalized {

  @override
  String get greetings => 'Hola, mundo!';

  @override
  String welcomeBack(Object name) => 'Bienvenido: ${name.toString()}';
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