import 'package:test_api/test_api.dart';

import '../example/localizations.dart';

void main() {
  test('simple test', () {
    expect(ENLocalized().greetings, equals('Hello, world!'));
    expect(ENLocalized().welcomeBack('Jhon'), equals("Welcome back: 'Jhon'"));
    expect(ENLocalized().welcomeBack(12), equals("Welcome back: '12'"));
    expect(ENLocalized().welcomeBack(34.56), equals("Welcome back: '34.56'"));
    expect(ENLocalized().welcomeBack(true), equals("Welcome back: 'true'"));
  });
}
