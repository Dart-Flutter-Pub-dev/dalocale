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
  String welcomeBack(Object name) => 'Welcome back: \'${name.toString()}zo\'';
}

class ESLocalized extends BaseLocalized {
  @override
  String get greetings => 'Hola, mundo!';

  @override
  String welcomeBack(Object name) => 'Bienvenido: \'${name.toString()}ito\'';
}

class Localized {
  static BaseLocalized get;

  static List<Locale> locales =
      localized.keys.map((String l) => Locale(l)).toList();

  static Map<String, BaseLocalized> localized = <String, BaseLocalized>{
    'en': ENLocalized(),
    'es': ESLocalized()
  };

  static void load(Locale locale) {
    get = localized[locale.languageCode];
  }
}

class CustomLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => Localized.locales
      .map((Locale l) => l.languageCode)
      .contains(locale.languageCode);

  @override
  Future<dynamic> load(Locale locale) {
    Localized.load(locale);
    return SynchronousFuture<dynamic>(Object());
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}
