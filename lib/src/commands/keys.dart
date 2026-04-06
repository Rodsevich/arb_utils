import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class KeysCommand extends Command {
  @override
  String get name => 'keys';
  @override
  String get description =>
      'List keys matching a regexp from the .arb files. Useful for checking existing translations.';

  @override
  String get invocation => '${super.invocation} <regexp> [files-paths...]';

  KeysCommand() {
    argParser.addMultiOption(
      'files',
      abbr: 'f',
      help:
          'Optional specific .arb files to check. If omitted, it recursively finds all .arb files.',
    );
  }

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException('ERROR! Expected a regexp to match keys.', invocation);
    }

    final pattern = argResults!.rest.first;
    final regex = RegExp(pattern);
    final specifiedFiles = argResults!['files'] as List<String>;

    final List<String> filePaths = [];
    if (specifiedFiles.isNotEmpty) {
      filePaths.addAll(specifiedFiles);
    } else if (argResults!.rest.length > 1) {
      filePaths.addAll(argResults!.rest.sublist(1));
    } else {
      find('*.arb', recursive: true).forEach((file) {
        filePaths.add(file);
      });
    }

    if (filePaths.isEmpty) {
      print(yellow('No .arb files found to search.'));
      return;
    }

    final Set<String> matchingKeys = {};

    for (final path in filePaths) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }
      try {
        final content = await file.readAsString();
        final Map<String, dynamic> jsonContent = json.decode(content);
        for (final key in jsonContent.keys) {
          if (!key.startsWith('@') && regex.hasMatch(key)) {
            matchingKeys.add(key);
          }
        }
      } catch (e) {
        print(red('Error reading $path: $e'));
      }
    }

    if (matchingKeys.isEmpty) {
      print(yellow('No matching keys found.'));
    } else {
      final sortedKeys = matchingKeys.toList()..sort();
      for (final key in sortedKeys) {
        print(key);
      }
    }
  }
}
