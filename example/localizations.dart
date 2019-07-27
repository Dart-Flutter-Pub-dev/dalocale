import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class BaseLocalized {
  String get greetings;

  String welcomeBack(String param1);

  String age(int param1);

  String totalCost(double param1);

  String appointment(String param1, String param2);
}

class ENLocalized extends BaseLocalized {
  @override
  String get greetings => 'Hello, world!';

  @override
  String welcomeBack(String param1) => 'Welcome back: \'${param1.toString()}\'';

  @override
  String age(int param1) => 'You are ${param1.toString()} years old';

  @override
  String totalCost(double param1) => 'The total cost is: ${param1.toString()} USD';

  @override
  String appointment(String param1, String param2) => 'Your appointment is on ${param1.toString()} at ${param2.toString()}';
}

class ESLocalized extends BaseLocalized {
  @override
  String get greetings => 'Hola, mundo!';

  @override
  String welcomeBack(String param1) => 'Bienvenido: \'${param1.toString()}\'';

  @override
  String age(int param1) => 'Tienes ${param1.toString()} años';

  @override
  String totalCost(double param1) => 'El coste total es de: ${param1.toString()} USD';

  @override
  String appointment(String param1, String param2) => 'Su cita es el ${param1.toString()} a las ${param2.toString()}';
}

class Localized {
  static BaseLocalized get;
  static Locale current;

  static List<Locale> locales =
      localized.keys.map((String l) => Locale(l)).toList();

  static Map<String, BaseLocalized> localized = <String, BaseLocalized>{
    'en': ENLocalized(),
    'es': ESLocalized()
  };

  static bool isSupported(Locale locale) =>
      locales.map((Locale l) => l.languageCode).contains(locale.languageCode);

  static void load(Locale locale) {
    current = locale;
    get = localized[locale.languageCode];
  }
}

class CustomLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => Localized.isSupported(locale);

  @override
  Future<dynamic> load(Locale locale) {
    Localized.load(locale);
    return SynchronousFuture<dynamic>(Object());
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}
