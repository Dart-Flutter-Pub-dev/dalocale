#!/bin/sh

set -e

DIR=`dirname $0`

flutter pub pub run dalocale:dalocale.dart ${DIR}/../i18n/,${DIR}/../errors/ ${DIR}/../localizations.dart en ${DIR}/..
flutter test ${DIR}/../test/dalocale_test.dart