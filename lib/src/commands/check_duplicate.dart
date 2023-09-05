import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class CheckDuplicateCommand extends Command {
  @override
  String get name => 'duplicate';

  @override
  String get description => 'Check for duplicate values in the arb file.';

  @override
  String get invocation =>
      '${super.invocation} <left-arb-file> <...arb-files-to-merge>';

  CheckDuplicateCommand();

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.isEmpty) {
      print(red('ERROR! Expected filepath to arb file.'));
      exit(1);
    }

    for (var filePath in argResults!.rest) {
      var file = File(filePath);
      if (!await file.exists()) {
        print(red('ERROR! Input-File does not exist: $filePath.'));
        exit(1);
      }
    }

    var arbContent = await File(argResults!.rest.first).readAsString();
    for (var i = 1; i < argResults!.rest.length; i++) {
      var mergeContent = await File(argResults!.rest[i]).readAsString();
      arbContent = mergeARBs(arbContent, mergeContent);
    }

    final Map<String, dynamic> arbJsonMap = json.decode(arbContent);
    arbJsonMap.removeWhere((key, value) => key.startsWith('@@'));
    arbJsonMap.removeWhere((key, value) => key.startsWith('@'));
    arbJsonMap.removeWhere((key, value) {
      if (value is String) {
        return RegExp(r'.*\{.*\}.*').hasMatch(value);
      } else {
        return false;
      }
    });

    final Map<String, dynamic> duplicateMap = {};
    for (final key in arbJsonMap.keys) {
      if (duplicateMap.containsKey(key)) {
        continue;
      }
      final value = arbJsonMap[key];
      final List<String> duplicateValueKeys = arbJsonMap.keys
          .where((k) => k != key)
          .where((k) => arbJsonMap[k] == value)
          .toList();
      if (duplicateValueKeys.isNotEmpty) {
        duplicateMap[key] = value;
        for (final k in duplicateValueKeys) {
          duplicateMap[k] = arbJsonMap[k];
        }
      }
    }

    if (duplicateMap.isNotEmpty) {
      print(red('ERROR! Duplicate values found:'));
      final encoder = JsonEncoder.withIndent('  ');
      print(red(encoder.convert(duplicateMap)));
      exit(1);
    }

    print(green('No duplicate values found.'));
  }
}
