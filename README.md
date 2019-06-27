# Dalocale

A Flutter package to easily support internationalization and localization in your project.

## Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies: 
  flutter_localizations: 
    sdk: flutter 

dev_dependencies:
  dalocale: ^1.4.0
```

## Example

### Creating localization files

Create a folder to store all the localizations in **json** format. The name of each file should match the locale that is representing. For example:

```
└─ assets
   └─ i18n
      ├─ en.json
      └─ es.json
```

Each localization file must contain a single **json** object with all the keys and values:

```json
{
    "key": "Value",
    "another.key": "Another value"
}
```

`Each key must start with a letter.`

For example:
```json
{
    "greetings": "Hello, world!",
    "welcome.back": "Welcome back: ${name}"
}
```

In the previous example, the key `welcome.back` contains a value with a parameter.

### Generating Dart code

To generate the Dart file containing all the localizations, run the following command:

```bash
flutter pub pub run dalocale:dalocale.dart INPUT_FOLDER OUTPUT_FILE
```

For example:

```bash
flutter pub pub run dalocale:dalocale.dart ./assets/i18n/ ./lib/foo/bar/localizations.dart
```

### Using generated code

In you `main.dart` file, add the auto-generated classes `CustomLocalizationsDelegate` and `Localized` to the app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_library/foo/bar/localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ...,
      localizationsDelegates: [
        const CustomLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: Localized.locales,
    );
  }
}
```

You can use the class `Localized` to have access to all the entries declared in the **json** files:

```dart
Text(Localized.get.greetings)
```

```dart
Text(Localized.get.welcomeBack('John'))
```