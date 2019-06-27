import 'package:flutter_test/flutter_test.dart';
import '../example/localizations.dart';

void main() {
  test('simple test', () {
    expect(ENLocalized().greetings, equals('Hello, world!'));
    expect(ENLocalized().welcomeBack('Jhon'), equals("Welcome back: 'Jhonzo'"));
    expect(ENLocalized().welcomeBack(12), equals("Welcome back: '12zo'"));
    expect(ENLocalized().welcomeBack(34.56), equals("Welcome back: '34.56zo'"));
    expect(ENLocalized().welcomeBack(true), equals("Welcome back: 'truezo'"));
  });
}
