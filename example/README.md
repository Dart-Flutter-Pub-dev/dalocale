# Example

## Creating localization files

Create a folder to store all the localizations in **json** format, for example:

```
└─ assets
   └─ i18n
      ├─ en.json
      └─ es.json
```

Each localization file contains a single **json** object with all the keys:

```json
{
    "key": "value"
    ...
}
```

Each key must start with a letter.

For example:
```json
{
    "greetings": "Hello, world!",
    "welcome.back": "Welcome back: ${name}"
}
```

In the previous example, the key `welcome.back` contains a value with a parameter.

## Generating Dart code

To generate the Dart file containing all the localizations, run the following command:

```bash
flutter pub pub run dalocale:generate_localizations.dart INPUT_FOLDER OUTPUT_FILE
```

For example:

```bash
flutter pub pub run dalocale:generate_localizations.dart ./assets/i18n/ ./lib/foo/bar/localizations.dart
```

## Using generated code

In you `main.dart` file, add the auto-generated class `CustomLocalizationsDelegate` to the `MaterialApp`:

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