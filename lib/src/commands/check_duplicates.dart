import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:arb_utils/src/primitives/check_duplicates.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class CheckDuplicatesCommand extends Command {
  @override
  String get name => 'duplicates';

  @override
  String get description => 'Check for duplicate values in the arb file.';

  @override
  String get invocation =>
      '${super.invocation} <left-arb-file> <...arb-files-to-merge>';

  CheckDuplicatesCommand();

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

    final duplicateMap = checkDuplicatesARB(arbContent);

    if (duplicateMap.isNotEmpty) {
      print(red('ERROR! Duplicate values found:'));
      final encoder = JsonEncoder.withIndent('  ');
      print(red(encoder.convert(duplicateMap)));
      exit(1);
    }

    print(green('No duplicate values found.'));
  }
}
