#!/usr/bin/env dart

library dalocale;

import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path/path.dart';

Future main(List<String> args) {
  final String input = args[0];
  final String output = args[1];
  final String defaultLocale = (args.length > 2) ? args[2] : '';
  final String? libFolder = (args.length > 3) ? args[3] : null;

  return generate(
    input: input.split(','),
    output: output,
    defaultLocale: defaultLocale,
    libFolder: libFolder,
  );
}

Future generate({
  required List<String> input,
  required String output,
  required String defaultLocale,
  String? libFolder,
}) async {
  final List<File> jsonFiles = [];

  for (final String path in input) {
    final List<File> files = getJsonFiles(path, defaultLocale);
    jsonFiles.addAll(files);
  }

  final List<LocalizationGroup> groups = await getGroups(jsonFiles);

  await generateFile(output, groups);

  if (libFolder != null) {
    final List<String> keys =
        groups[0].entries.map((LocalizationEntry e) => e.keyName()).toList();
    final Directory root = Directory(libFolder);

    final List<FileSystemEntity> entities = root.listSync(recursive: true);
    final File outPutFile = File(output);

    for (final FileSystemEntity entity in entities) {
      if (entity.path.endsWith('.dart') && (entity.path != outPutFile.path)) {
        keys.removeWhere((String key) => existsInFile(key, entity));
      }

      if (keys.isEmpty) {
        break;
      }
    }

    if (keys.isNotEmpty) {
      print('Unused keys:');

      for (final String key in keys) {
        print(key);
      }
    }
  }
}

bool existsInFile(String key, FileSystemEntity entity) {
  final File file = File(entity.path);
  final String content = file.readAsStringSync();

  return content.contains(key);
}

List<File> getJsonFiles(String root, String defaultLocale) {
  final Directory folder = Directory(root);
  final List<FileSystemEntity> contents = folder.listSync(
    recursive: false,
    followLinks: false,
  );
  final List<File> result = <File>[];

  for (final FileSystemEntity fileOrDir in contents) {
    if (fileOrDir is File) {
      result.add(File(fileOrDir.path));
    }
  }

  if (defaultLocale.isNotEmpty) {
    final File? defaultFile = result.firstWhereOrNull(
      (File f) => basename(f.path) == '$defaultLocale.json',
    );

    if (defaultFile == null) {
      throw Exception(
        'Default locale "$defaultLocale" not found in input files',
      );
    }

    final List<File> rest =
        result
            .where((File f) => basename(f.path) != '$defaultLocale.json')
            .toList();

    result.clear();
    result.add(defaultFile);
    result.addAll(rest);
  }

  for (final File file in result) {
    sortFile(file);
  }

  return result;
}

void sortFile(File file) {
  String content = file.readAsStringSync();
  final Map<String, dynamic> json = jsonDecode(content);

  final List<String> sortedKeys = json.keys.toList()..sort();
  final Map<String, dynamic> map = <String, dynamic>{};

  for (final String key in sortedKeys) {
    map[key] = json[key];
  }

  const JsonEncoder encoder = JsonEncoder.withIndent('    ');
  content = encoder.convert(map);

  file.writeAsStringSync(content, mode: FileMode.write);
}

Future<List<LocalizationGroup>> getGroups(List<File> files) async {
  final Map<String, LocalizationGroup> groups = {};

  for (final File file in files) {
    final String filename = basename(file.path);
    final List<String> parts = filename.split('.');
    final List<LocalizationEntry> entries = await getEntries(file);
    final String locale = parts[0].toLowerCase();

    if (groups.containsKey(locale)) {
      final LocalizationGroup group = groups[locale]!;
      group.entries.addAll(entries);
    } else {
      groups[locale] = LocalizationGroup(locale, entries);
    }
  }

  return groups.values.toList();
}

Future<List<LocalizationEntry>> getEntries(File file) async {
  final String content = await file.readAsString();
  final Map<String, dynamic> json = jsonDecode(content);
  final List<LocalizationEntry> entries = <LocalizationEntry>[];

  for (final String entry in json.keys) {
    entries.add(LocalizationEntry.create(entry, json[entry]));
  }

  return entries;
}

Future<void> generateFile(String output, List<LocalizationGroup> groups) async {
  final SourceFile file = SourceFile(output);
  file.clear();

  // imports
  file.write("import 'package:flutter/foundation.dart';\n");
  file.write("import 'package:flutter/widgets.dart';\n");
  file.write('\n');

  // base
  file.write(groups[0].base());

  // concrete
  for (final LocalizationGroup group in groups) {
    file.write('\n${group.concrete()}');
  }

  // localized
  file.write('\nclass Localized {\n');
  file.write('  static late BaseLocalized get;\n');
  file.write('  static late Locale current;\n');
  file.write('\n');
  file.write('  static List<Locale> locales =\n');
  file.write('      localized.keys.map(Locale.new).toList();\n');
  file.write('\n');
  file.write(
    '  static Map<String, BaseLocalized> localized = <String, BaseLocalized>{\n',
  );

  for (int i = 0; i < groups.length; i++) {
    final LocalizationGroup group = groups[i];
    file.write('    ${group.mapEntry}');

    if (i < (groups.length - 1)) {
      file.write(',\n');
    } else {
      file.write('\n');
    }
  }
  file.write('  };\n');
  file.write('\n');
  file.write('  static bool isSupported(Locale locale) =>\n');
  file.write(
    '      locales.map((Locale l) => l.languageCode).contains(locale.languageCode);\n',
  );
  file.write('\n');
  file.write('  static void load(Locale locale) {\n');
  file.write('    current = locale;\n');
  file.write('    get = localized[locale.languageCode]!;\n');
  file.write('  }\n');
  file.write('}\n');

  // delegate
  file.write(
    '\nclass CustomLocalizationsDelegate extends LocalizationsDelegate<dynamic> {\n',
  );
  file.write('  const CustomLocalizationsDelegate();\n');
  file.write('\n');
  file.write('  @override\n');
  file.write(
    '  bool isSupported(Locale locale) => Localized.isSupported(locale);\n',
  );
  file.write('\n');
  file.write('  @override\n');
  file.write('  Future<dynamic> load(Locale locale) {\n');
  file.write('    Localized.load(locale);\n');
  file.write('    return SynchronousFuture<dynamic>(Object());\n');
  file.write('  }\n');
  file.write('\n');
  file.write('  @override\n');
  file.write(
    '  bool shouldReload(CustomLocalizationsDelegate old) => false;\n',
  );
  file.write('}\n');
}

class LocalizationGroup {
  final String locale;
  final List<LocalizationEntry> entries;

  LocalizationGroup(this.locale, this.entries);

  String get name => locale.toUpperCase();

  String get mapEntry => "'$locale': ${name}Localized()";

  String base() {
    String result = 'abstract class BaseLocalized {';

    for (final LocalizationEntry entry in entries) {
      result += entry.lineBase();
    }

    return '$result }\n';
  }

  String concrete() {
    String result = 'class ${name}Localized extends BaseLocalized {';

    for (final LocalizationEntry entry in entries) {
      result += entry.lineConcrete;
    }

    return '$result }\n';
  }
}

class LocalizationEntry {
  final String key;
  final String value;
  final List<String?> params;

  LocalizationEntry(this.key, this.value, [this.params = const <String>[]]);

  factory LocalizationEntry.create(String key, String value) {
    String finalValue = value;
    final RegExp exp = RegExp(r'%[0-9]\$([sdf])');
    final List<String?> params =
        exp
            .allMatches(finalValue)
            .toList()
            .map((Match r) => r.group(1))
            .toList();

    for (int i = 1; i <= params.length; i++) {
      final String? param = params[i - 1];
      finalValue = finalValue.replaceFirst(
        '%$i\$$param',
        '\${param$i.toString()}',
      );
    }

    return LocalizationEntry(key, finalValue, params);
  }

  String get lineConcrete => '\n  @override\n${_line(value)}';

  String lineBase() {
    if (params.isEmpty) {
      return '\n  String get ${keyName()};\n';
    } else {
      return '\n  String ${keyName()}(${_parameterList(params)});\n';
    }
  }

  String _line(String value) {
    if (params.isEmpty) {
      if (value.contains('\r') || value.contains('\n')) {
        return "  String get ${keyName()} => '''$value''';\n";
      } else if (value.contains("'")) {
        return '  String get ${keyName()} => "$value";\n';
      } else {
        return "  String get ${keyName()} => '$value';\n";
      }
    } else {
      if (value.contains('\r') || value.contains('\n')) {
        return "  String ${keyName()}(${_parameterList(params)}) => '''$value''';\n";
      } else if (value.contains("'")) {
        return '  String ${keyName()}(${_parameterList(params)}) => "$value";\n';
      } else {
        return "  String ${keyName()}(${_parameterList(params)}) => '$value';\n";
      }
    }
  }

  bool isValidCharacter(String character) {
    final regex = RegExp(r'^[a-zA-Z0-9_]$');

    return regex.hasMatch(character);
  }

  String keyName() {
    String result = '';
    bool shouldCapitalize = false;

    for (int i = 0; i < key.length; i++) {
      final String char = key[i];

      if (!isValidCharacter(char)) {
        shouldCapitalize = true;
      } else if (shouldCapitalize) {
        result += char.toUpperCase();
        shouldCapitalize = false;
      } else {
        result += char;
      }
    }

    return result;
  }

  String _parameterList(List<String?> parameters) {
    String result = '';

    for (int i = 1; i <= parameters.length; i++) {
      final String? parameter = parameters[i - 1];
      result += result.isEmpty ? '' : ', ';

      if (parameter == 's') {
        result += 'String';
      } else if (parameter == 'd') {
        result += 'int';
      } else if (parameter == 'f') {
        result += 'double';
      } else {
        result += 'Object';
      }

      result += ' param$i';
    }

    return result;
  }
}

class SourceFile {
  final File file;

  SourceFile(String path) : file = File(path);

  void clear() => file.writeAsStringSync('');

  void write(String content) =>
      file.writeAsStringSync(content, mode: FileMode.append);
}
