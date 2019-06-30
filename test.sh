#!/bin/sh

flutter pub pub run dalocale:dalocale.dart ./example/i18n/ ./example/localizations.dart en
flutter test test/dalocale_test.dart