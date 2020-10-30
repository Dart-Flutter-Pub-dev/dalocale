import 'package:flutter_test/flutter_test.dart';
import '../localizations.dart';

void main() {
  test('simple test', () {
    expect(ENLocalized().greetings, equals('Hello, world!'));
    expect(ENLocalized().welcomeBack('Jhon'), equals("Welcome back: 'Jhon'"));
    expect(ENLocalized().age(12), equals('You are 12 years old'));
    expect(
        ENLocalized().totalCost(34.56), equals('The total cost is: 34.56 USD'));
    expect(ENLocalized().appointment('Monday', '13:00'),
        equals('Your appointment is on Monday at 13:00'));
  });
}
