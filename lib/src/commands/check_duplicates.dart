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
  String get description => 'Check for duplicated values in the arb file.';

  @override
  String get invocation => '${super.invocation} <arb-file-target>';

  CheckDuplicatesCommand();

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
      print(yellow(
          'WARNING! Ignoring excess arguments ${filePaths.sublist(1)}'));
    }

    final file = File(filePaths.first);
    if (!await file.exists()) {
      print(red('ERROR! File ${file.path} does not exists'));
      return;
    }

    var arbContents = await file.readAsString();
    for (var i = 1; i < filePaths.length; i++) {
      var mergeContent = await File(filePaths[i]).readAsString();
      arbContents = mergeARBs(arbContents, mergeContent);
    }

    final duplicateMap = checkDuplicatesARB(arbContents);

    if (duplicateMap.isNotEmpty) {
      print(red('ERROR! Duplicated values found:'));
      final encoder = JsonEncoder.withIndent('  ');
      print(red(encoder.convert(duplicateMap)));
      exit(1);
    }

    print(green('No duplicated values found.'));
  }
}
