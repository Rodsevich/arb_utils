import 'dart:async';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class SortCommand extends Command {
  @override
  String get name => 'sort';
  @override
  String get description =>
      'Sorts the keys in the file in alphabetical order respecting their metadata.';

  @override
  String get invocation => '${super.invocation} <arb-file-target>';

  SortCommand() {
    argParser.addFlag('case-insensitive',
        abbr: 'i',
        help: 'Wether to distinguish between lowercase '
            'and uppercase while ordering the keys.',
        negatable: true,
        defaultsTo: true);
    argParser.addFlag('natural-ordering',
        abbr: 'n',
        help: 'Wether to take numbers as a single character '
            'and order them according to their numeric value (instead of ASCII one).',
        negatable: true,
        defaultsTo: true);
    argParser.addFlag('descending',
        abbr: 'd',
        help: 'Sort in descending order.',
        negatable: true,
        defaultsTo: false);
  }

  FutureOr<void> run() async {
    if (argResults!.rest.isEmpty) {
      print(red('ERROR! Expected filepath to arb file.'));
      return;
    } else if (argResults!.rest.length > 1) {
      print(yellow(
          'WARNING! Ignoring excess arguments ${argResults!.rest.sublist(1)}'));
    }

    final file = File(argResults!.rest.first);
    if (!await file.exists()) {
      print(red('ERROR! File ${file.path} does not exists'));
      return;
    }

    var arbContents = await file.readAsString();
    arbContents = sortARB(arbContents,
        caseInsensitive: argResults!['case-insensitive'],
        naturalOrdering: argResults!['natural-ordering'],
        descendingOrdering: argResults!['descending']);

    await file.writeAsString(arbContents);
  }
}
