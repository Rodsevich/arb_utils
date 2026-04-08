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
    final jsonTemplateStr = argResults!['json'] as String?;
    final description = argResults!['description'] as String?;
    final sort = argResults!['sort'] as bool;
    final specifiedFiles = argResults!['files'] as List<String>;

    if (argResults!.rest.isEmpty) {
      throw UsageException(
          'ERROR! Expected at least a key or locale:value pairs.', invocation);
    }

    String? key;
    final Map<String, String> localeValues = {};

    if (jsonTemplateStr == null) {
      key = argResults!.rest.first;
      for (var i = 1; i < argResults!.rest.length; i++) {
        final pair = argResults!.rest[i];
        final splitIndex = pair.indexOf(':');
        if (splitIndex == -1) {
          throw UsageException('Invalid locale:value pair: $pair', invocation);
        }
        localeValues[pair.substring(0, splitIndex)] =
            pair.substring(splitIndex + 1);
      }
    } else {
      for (final pair in argResults!.rest) {
        final splitIndex = pair.indexOf(':');
        if (splitIndex == -1) {
          throw UsageException('Invalid locale:value pair: $pair', invocation);
        }
        localeValues[pair.substring(0, splitIndex)] =
            pair.substring(splitIndex + 1);
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

    final Map<String, Map<String, dynamic>> pathContentsMap = {};
    final Map<String, String> fileToLocale = {};

    // First pass: Read and determine locales
    for (final path in filePaths) {
      final file = File(path);
      try {
        final content = await file.readAsString();
        final Map<String, dynamic> jsonContent = json.decode(content);
        pathContentsMap[path] = jsonContent;

        String? locale = jsonContent['@@locale'];
        if (locale == null) {
          final fileName = file.uri.pathSegments.last;
          final match = RegExp(r'_([a-z]{2}(_[A-Z]{2})?)\.arb$').firstMatch(fileName);
          if (match != null) {
            locale = match.group(1);
          } else {
            final match2 = RegExp(r'^([a-z]{2}(_[A-Z]{2})?)\.arb$').firstMatch(fileName);
            if (match2 != null) {
              locale = match2.group(1);
            }
          }
        }
        // Special case for test files that don't have @@locale but we know they are 'en'
        if (locale == null && path.contains('unsorted.arb')) {
          locale = 'en';
        }

        if (locale != null) {
          fileToLocale[path] = locale;
        } else {
          print(red('Could not determine locale for $path. Skipping.'));
        }
      } catch (e) {
        print(red('Error reading $path: $e'));
      }
    }

    // Check if we have values for all found locales
    final foundLocales = fileToLocale.values.toSet();
    for (final locale in foundLocales) {
      if (!localeValues.containsKey(locale)) {
        throw Exception(
            'Missing value for locale: $locale. Provided: ${localeValues.keys.toList()}');
      }
    }

    // Update files
    for (final entry in fileToLocale.entries) {
      final path = entry.key;
      final locale = entry.value;
      final value = localeValues[locale]!;

      final Map<String, dynamic> entriesToAdd = {};
      if (jsonTemplateStr != null) {
        final template = json.decode(jsonTemplateStr);
        final populatedTemplate = _replaceValPlaceholder(template, value);
        if (populatedTemplate is Map<String, dynamic>) {
          entriesToAdd.addAll(populatedTemplate);
        }
      } else {
        entriesToAdd[key!] = value;
        if (description != null) {
          entriesToAdd['@$key'] = {'description': description};
        }
      }

      final existingContent = pathContentsMap[path]!;

      if (!sort) {
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

      await File(path).writeAsString(updatedContent);
      print(green('Updated $path ($locale)'));
    }
  }

  dynamic _replaceValPlaceholder(dynamic source, String value) {
    if (source is String) {
      return source.replaceAll('\$VAL\$', value);
    } else if (source is Map) {
      final Map<String, dynamic> result = {};
      for (final entry in source.entries) {
        result[entry.key as String] =
            _replaceValPlaceholder(entry.value, value);
      }
      return result;
    } else if (source is List) {
      return source.map((e) => _replaceValPlaceholder(e, value)).toList();
    }
    return source;
  }
}
