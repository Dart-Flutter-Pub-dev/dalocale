#!/bin/sh

flutter pub pub run dalocale:dalocale.dart ./example/i18n/ ./example/localizations.dart
flutter test test/dalocale_test.dart