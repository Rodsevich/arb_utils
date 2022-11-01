import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../primitives/add_missing_metadata.dart';

class GenerateMetaCommand extends Command {
  @override
  String get name => 'generate-meta';
  @override
  String get description => 'Adds missing metadata to an arb file.';

  @override
  String get invocation => '${super.invocation} <arb-file-target>';

  GenerateMetaCommand() {
    argParser.addFlag('quiet',
        abbr: 'q', help: 'Do not output.', negatable: false, defaultsTo: false);
    argParser.addFlag('verbose',
        abbr: 'v',
        help: 'List the generated metadata.',
        negatable: false,
        defaultsTo: false);
  }

  FutureOr<void> run() async {
    final args = argResults!.rest;

    if (args.isEmpty) {
      print(red('ERROR! Expected filepath to arb file.'));
      return;
    } else if (args.length > 1) {
      print(red('WARNING! Ignoring excess arguments ${args.sublist(1)}'));
    }

    final file = File(args.first);
    if (!await file.exists()) {
      print(red('ERROR! File ${file.path} does not exists'));
      return;
    }

    final oldArbContents = await file.readAsString();
    final newArbContents = addMissingMetadata(oldArbContents);

    await file.writeAsString(newArbContents);

    if (!argResults!['quiet']) {
      final oldArbContentsLines = oldArbContents.split('\n');
      final newArbContentsLines = newArbContents.split('\n');
      newArbContentsLines.removeWhere(
          (line) => oldArbContentsLines.contains(line) || !line.contains('@'));
      final count = newArbContentsLines.length;
      if (count >= 1) {
        print(yellow('Added ') +
            green(count.toString()) +
            yellow(' missing metadata tag${count == 1 ? '' : 's'} '
                'to ${file.path + (argResults!['verbose'] ? ':' : '.')}'));
        if (argResults!['verbose']) {
          print(newArbContentsLines.join('\n'));
        }
      } else {
        print(yellow('No metadata tags added to ${file.path}'));
      }
    }
  }
}
