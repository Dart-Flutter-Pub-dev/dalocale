#!/usr/bin/env dart
library dalocale;

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

Future<void> main(List<String> args) async {
  final String input = args[0];
  final String output = args[1];
  final String defaultLocale = (args.length > 2) ? args[2] : '';

  final List<File> jsonFiles = getJsonFiles(input, defaultLocale);
  final List<LocalizationGroup> groups = await getGroups(jsonFiles);

  generateFile(output, groups);

  if (args.length > 3) {
    final List<String> keys =
        groups[0].entries.map((LocalizationEntry e) => e.keyName()).toList();
    final Directory root = Directory(args[3]);

    final List<FileSystemEntity> entities = root.listSync(recursive: true);
    final File outPutFile = File(output);

    for (FileSystemEntity entity in entities) {
      if (entity.path.endsWith('.dart') && (entity.path != outPutFile.path)) {
        keys.removeWhere((String key) => existsInFile(key, entity));
      }

      if (keys.isEmpty) {
        break;
      }
    }

    if (keys.isNotEmpty) {
      print('Unused keys:');

      for (String key in keys) {
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
  final List<FileSystemEntity> contents =
      folder.listSync(recursive: false, followLinks: false);
  final List<File> result = <File>[];

  for (FileSystemEntity fileOrDir in contents) {
    if (fileOrDir is File) {
      result.add(File(fileOrDir.path));
    }
  }

  if (defaultLocale.isNotEmpty) {
    final File defaultFile = result.firstWhere(
        (File f) => basename(f.path) == '$defaultLocale.json',
        orElse: () => null);

    if (defaultFile == null) {
      throw Exception(
          'Default locale "$defaultLocale" not found in input files');
    }

    final List<File> rest = result
        .where((File f) => basename(f.path) != '$defaultLocale.json')
        .toList();

    result.clear();
    result.add(defaultFile);
    result.addAll(rest);
  }

  return result;
}

Future<List<LocalizationGroup>> getGroups(List<File> files) async {
  final List<LocalizationGroup> groups = <LocalizationGroup>[];

  for (File file in files) {
    final String filename = basename(file.path);
    final List<String> parts = filename.split('.');
    final List<LocalizationEntry> entries = await getEntries(file);

    groups.add(LocalizationGroup(parts[0].toLowerCase(), entries));
  }

  return groups;
}

Future<List<LocalizationEntry>> getEntries(File file) async {
  final String content = await file.readAsString();
  final Map<String, dynamic> json = jsonDecode(content);
  final List<LocalizationEntry> entries = <LocalizationEntry>[];

  for (String key in json.keys) {
    entries.add(LocalizationEntry.create(key, json[key]));
  }

  return entries;
}

Future<void> generateFile(String output, List<LocalizationGroup> groups) async {
  final SourceFile managerfile = SourceFile('${output}/localization_manager.dart');
  final SourceFile stringFile = SourceFile('${output}/localizations.dart');
  managerfile.clear();
  stringFile.clear();

  // base
  stringFile.write(groups[0].base());

  // concrete
  for (LocalizationGroup group in groups) {
    stringFile.write('\n${group.concrete()}');
  }

  // imports
  managerfile.write("import 'package:flutter/foundation.dart';\n");
  managerfile.write("import 'package:flutter/widgets.dart';\n");
  managerfile.write("import './localizations.dart';\n");

  managerfile.write('\nclass LocalizationManager {\n');
  managerfile.write('  static Locale currentLocale;\n');
  managerfile.write('  static List<String> supportedLanguageCodes = [');
  managerfile.write(groups.map((LocalizationGroup group) => "'${group.locale}'").join(', '));
  managerfile.write('];\n');
  managerfile.write('  static List<Locale> get locales =>\n');
  managerfile.write('      supportedLanguageCodes.map((String l) => Locale(l)).toList();\n');
  managerfile.write('\n');

  managerfile.write('  static bool isSupported(Locale locale) =>\n');
  managerfile.write(
      '      locales.map((Locale l) => l.languageCode).contains(locale.languageCode);\n');
  managerfile.write('\n');
  managerfile.write('  static void load(Locale locale) {\n');
  managerfile.write('    currentLocale = locale;\n');
  managerfile.write('    Localized.get = localizedForLocal(locale);\n');
  managerfile.write('  }\n');
  managerfile.write('\n');

  managerfile.write(
      '  static BaseLocalized localizedForLocal(Locale locale) {\n');
  managerfile.write('    switch (locale.languageCode) {\n');
  for (int i = 0; i < groups.length; i++) {
    final LocalizationGroup group = groups[i];
    managerfile.write("     case '${group.locale}': return ${group.className()}();\n");
  }
  final LocalizationGroup defaultGroup = groups[0];
  managerfile.write("     default: return ${defaultGroup.className()}();\n");
  managerfile.write('    }\n');
  managerfile.write('  }\n');
  managerfile.write('}\n');

  // delegate
  managerfile.write(
      '\nclass CustomLocalizationsDelegate extends LocalizationsDelegate<dynamic> {\n');
  managerfile.write('  const CustomLocalizationsDelegate();\n');
  managerfile.write('\n');
  managerfile.write('  @override\n');
  managerfile.write(
      '  bool isSupported(Locale locale) => LocalizationManager.isSupported(locale);\n');
  managerfile.write('\n');
  managerfile.write('  @override\n');
  managerfile.write('  Future<dynamic> load(Locale locale) {\n');
  managerfile.write('    LocalizationManager.load(locale);\n');
  managerfile.write('    return SynchronousFuture<dynamic>(Object());\n');
  managerfile.write('  }\n');
  managerfile.write('\n');
  managerfile.write('  @override\n');
  managerfile.write(
      '  bool shouldReload(CustomLocalizationsDelegate old) => false;\n');
  managerfile.write('}\n');

  // localized
  stringFile.write('\nclass Localized {\n');
  stringFile.write("  static BaseLocalized get = ${defaultGroup.className()}();\n");
  stringFile.write('}\n');
}

class LocalizationGroup {
  final String locale;
  final List<LocalizationEntry> entries;

  LocalizationGroup(this.locale, this.entries);

  String className() {
    return locale.toUpperCase() + 'Localized';
  }

  String base() {
    String result = 'abstract class BaseLocalized {';

    for (LocalizationEntry entry in entries) {
      result += entry.lineBase();
    }

    result += '}\n';

    return result;
  }

  String concrete() {
    String result = 'class ${className()} extends BaseLocalized {';

    for (LocalizationEntry entry in entries) {
      result += entry.lineConcrete();
    }

    result += '}\n';

    return result;
  }
}

class LocalizationEntry {
  final String key;
  final String value;
  final List<String> params;

  LocalizationEntry(this.key, this.value, [this.params = const <String>[]]);

  static LocalizationEntry create(String key, String value) {
    final RegExp exp = RegExp(r'%[0-9]\$([sdf])');
    final List<String> params =
        exp.allMatches(value).toList().map((Match r) => r.group(1)).toList();

    for (int i = 1; i <= params.length; i++) {
      final String param = params[i - 1];
      value = value.replaceFirst('%$i\$$param', '\$\{param$i.toString()\}');
    }

    value = value.replaceAll("'", "\\'");

    return LocalizationEntry(key, value, params);
  }

  String lineConcrete() {
    String result = '\n  @override\n';
    result += _line(value);

    return result;
  }

  String lineBase() {
    if (params.isEmpty) {
      return '\n  String get ${keyName()};\n';
    } else {
      return '\n  String ${keyName()}(${_parameterList(params)});\n';
    }
  }

  String _line(String value) {
    if (params.isEmpty) {
      return "  String get ${keyName()} => '$value';\n";
    } else {
      return "  String ${keyName()}(${_parameterList(params)}) => '$value';\n";
    }
  }

  String keyName() {
    String result = '';
    bool shouldCapitalize = false;

    for (int i = 0; i < key.length; i++) {
      final String char = key[i];

      if (char == '.') {
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

  String _parameterList(List<String> parameters) {
    String result = '';

    for (int i = 1; i <= parameters.length; i++) {
      final String parameter = parameters[i - 1];
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

  void clear() {
    file.writeAsStringSync('');
  }

  void write(String content) {
    file.writeAsStringSync(content, mode: FileMode.append);
  }
}
