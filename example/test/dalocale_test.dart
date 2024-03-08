import 'package:flutter_test/flutter_test.dart';
import '../localizations.dart';

void main() {
  test('simple test', () {
    expect(ENLocalized().greetings, equals('Hello, world!'));
    expect(ENLocalized().welcomeBack('John'), equals("Welcome back: 'John'"));
    expect(ENLocalized().age(12), equals('You are 12 years old'));
    expect(
        ENLocalized().totalCost(34.56), equals('The total cost is: 34.56 USD'));
    expect(ENLocalized().appointment('Monday', '13:00'),
        equals('Your appointment is on Monday at 13:00'));
    expect(ENLocalized().multiline.split('\n').length, equals(2));
    expect(ENLocalized().multilineParams('Gold', 'Silver'),
        equals('The first price is Gold\nThe second price is Silver'));
  });
}
