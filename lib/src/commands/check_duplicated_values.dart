import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arb_utils/src/primitives/check_duplicated_values.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class CheckDuplicatedValuesSubCommand extends Command {
  @override
  String get name => 'values';

  @override
  String get description => 'Check for duplicated values in the arb file.';

  @override
  String get invocation => '${super.invocation} <arb-file-target>';

  CheckDuplicatedValuesSubCommand();

  @override
  FutureOr<void> run() async {
    final filePaths = argResults?.rest;
    if (filePaths == null) {
      print(red('ERROR! Unexpected state. argResults is null.'));
      exit(1);
    }
    if (filePaths.isEmpty) {
      print(red('ERROR! Expected filepath to arb file.'));
      exit(2);
    } else if (filePaths.length > 1) {
      print(
        yellow('WARNING! Ignoring excess arguments ${filePaths.sublist(1)}'),
      );
    }

    final file = File(filePaths.first);
    if (!await file.exists()) {
      print(red('ERROR! File ${file.path} does not exist'));
      exit(2);
    }

    final arbContents = await file.readAsString();
    final duplicateMap = checkDuplicatedValuesARB(arbContents);

    if (duplicateMap.isNotEmpty) {
      print(red('ERROR! Duplicated values found:'));
      final encoder = JsonEncoder.withIndent('  ');
      print(red(encoder.convert(duplicateMap)));
      exit(1);
    }

    print(green('No duplicated values found.'));
  }
}
