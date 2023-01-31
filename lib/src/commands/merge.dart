import 'dart:async';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class MergeCommand extends Command {
  @override
  String get name => 'merge';
  @override
  String get description =>
      'Merge multiple arb files and output the resulting arb file. One may specify an output file. The files are merged in input order.';

  @override
  String get invocation => '${super.invocation} <left-arb-file> <...arb-files-to-merge>';

  MergeCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'The optional output file. If omitted, the output of the merge operation will be printed to stdout.',
      valueHelp: 'output-file',
    );
    argParser.addFlag(
      'inline',
      abbr: 'i',
      help:
          'Whether the output should be written into the first input file (inline-edit). Takes precedence over --output.',
      negatable: false,
      defaultsTo: false,
    );
  }

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.isEmpty || argResults!.rest.length < 2) {
      print(red('ERROR! Expected filepath to at least two arb files.'));
      return;
    }

    for (var filePath in argResults!.rest) {
      var file = File(filePath);
      if (!await file.exists()) {
        print(red('ERROR! Input-File does not exist: $filePath.'));
        return;
      }
    }

    var arbContent = await File(argResults!.rest.first).readAsString();
    for (var i = 1; i < argResults!.rest.length; i++) {
      var mergeContent = await File(argResults!.rest[i]).readAsString();
      arbContent = mergeARBs(arbContent, mergeContent);
    }

    if (argResults!['inline']) {
      await File(argResults!.rest.first).writeAsString(arbContent);
    } else if (argResults!.options.contains('output')) {
      var outputFile = File(argResults!['output']);
      await outputFile.create(recursive: true);
      await outputFile.writeAsString(arbContent);
    } else {
      print(arbContent);
    }
  }
}
