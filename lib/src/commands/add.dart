import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class AddCommand extends Command {
  @override
  String get name => 'add';
  @override
  String get description =>
      'Add entries to one or more arb files. By default it appends entries to the end of the files.';

  @override
  String get invocation =>
      '${super.invocation} <key> [locale:value...] OR ${super.invocation} --json \'<template>\' [locale:value...]';

  AddCommand() {
    argParser.addOption(
      'json',
      abbr: 'j',
      help:
          'A JSON template to add. Use \$VAL\$ as a placeholder for the locale-specific value.',
    );
    argParser.addOption(
      'description',
      abbr: 'd',
      help: 'An optional description for the key (only used without --json).',
    );
    argParser.addMultiOption(
      'files',
      abbr: 'f',
      help:
          'Optional specific .arb files to update. If omitted, it recursively finds all .arb files.',
    );
    argParser.addFlag(
      'sort',
      abbr: 's',
      help: 'Whether to sort the files after adding the new entries.',
      defaultsTo: false,
    );
  }

  @override
  FutureOr<void> run() async {
    final jsonTemplate = argResults!['json'] as String?;
    final description = argResults!['description'] as String?;
    final sort = argResults!['sort'] as bool;
    final specifiedFiles = argResults!['files'] as List<String>;

    if (argResults!.rest.isEmpty) {
      throw UsageException('ERROR! Expected at least a key or locale:value pairs.', invocation);
    }

    String? key;
    final Map<String, String> localeValues = {};

    if (jsonTemplate == null) {
      key = argResults!.rest.first;
      for (var i = 1; i < argResults!.rest.length; i++) {
        final pair = argResults!.rest[i];
        final splitIndex = pair.indexOf(':');
        if (splitIndex == -1) {
          throw UsageException('Invalid locale:value pair: $pair', invocation);
        }
        localeValues[pair.substring(0, splitIndex)] = pair.substring(splitIndex + 1);
      }
    } else {
      for (final pair in argResults!.rest) {
        final splitIndex = pair.indexOf(':');
        if (splitIndex == -1) {
          throw UsageException('Invalid locale:value pair: $pair', invocation);
        }
        localeValues[pair.substring(0, splitIndex)] = pair.substring(splitIndex + 1);
      }
    }

    final List<String> filePaths = [];
    if (specifiedFiles.isNotEmpty) {
      filePaths.addAll(specifiedFiles);
    } else {
      find('*.arb', recursive: true).forEach((file) {
        filePaths.add(file);
      });
    }

    if (filePaths.isEmpty) {
      print(yellow('No .arb files found to update.'));
      return;
    }

    // Map files to their locales
    final Map<String, String> fileToLocale = {};
    for (final path in filePaths) {
      final file = File(path);
      final content = await file.readAsString();
      final Map<String, dynamic> jsonContent = json.decode(content);
      String? locale = jsonContent['@@locale'];
      if (locale == null) {
        // Try to infer from filename (e.g. app_en.arb -> en)
        final fileName = file.uri.pathSegments.last;
        final match = RegExp(r'_([a-z]{2}(_[A-Z]{2})?)\.arb$').firstMatch(fileName);
        if (match != null) {
          locale = match.group(1);
        } else {
          // Check for common locale names in the filename without prefix
          final match2 = RegExp(r'^([a-z]{2}(_[A-Z]{2})?)\.arb$').firstMatch(fileName);
          if (match2 != null) {
            locale = match2.group(1);
          }
        }
      }

      if (locale != null) {
        fileToLocale[path] = locale;
      } else {
        print(red('Could not determine locale for $path. Skipping.'));
      }
    }

    // Check if we have values for all found locales
    final foundLocales = fileToLocale.values.toSet();
    for (final locale in foundLocales) {
      if (!localeValues.containsKey(locale)) {
        throw Exception('Missing value for locale: $locale. Provided: ${localeValues.keys.toList()}');
      }
    }

    // Update files
    for (final entry in fileToLocale.entries) {
      final path = entry.key;
      final locale = entry.value;
      final value = localeValues[locale]!;

      final Map<String, dynamic> entriesToAdd = {};
      if (jsonTemplate != null) {
        entriesToAdd.addAll(
            json.decode(jsonTemplate.replaceAll('\$VAL\$', value)));
      } else {
        entriesToAdd[key!] = value;
        if (description != null) {
          entriesToAdd['@$key'] = {'description': description};
        }
      }

      final file = File(path);
      var arbContent = await file.readAsString();
      final Map<String, dynamic> existingContent = json.decode(arbContent);

      if (!sort) {
        // If not sorting, we want new keys at the end.
        // If we just use existingContent.addAll(entriesToAdd), existing keys stay where they were.
        // If we want it strictly at the tail, we might want to remove then add back.
        for (var k in entriesToAdd.keys) {
          existingContent.remove(k);
        }
        existingContent.addAll(entriesToAdd);
      } else {
        existingContent.addAll(entriesToAdd);
      }

      String updatedContent;
      if (sort) {
        updatedContent = sortARB(json.encode(existingContent));
      } else {
        final encoder = JsonEncoder.withIndent('  ');
        updatedContent = '${encoder.convert(existingContent)}\n';
      }

      await file.writeAsString(updatedContent);
      print(green('Updated $path ($locale)'));
    }
  }
}
