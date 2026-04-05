import 'dart:async';
import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

class AddCommand extends Command {
  @override
  String get name => 'add';
  @override
  String get description =>
      'Add entries to one or more arb files. If no files are specified, it will look for all .arb files in the current directory and its subdirectories.';

  @override
  String get invocation => '${super.invocation} <json-to-add> [arb-file-paths]';

  @override
  FutureOr<void> run() async {
    if (argResults!.rest.isEmpty) {
      throw UsageException(
          'ERROR! Expected a JSON string to add.', invocation);
    }

    final jsonToAdd = argResults!.rest.first;
    final List<String> filePaths = [];

    if (argResults!.rest.length > 1) {
      filePaths.addAll(argResults!.rest.sublist(1));
    } else {
      // Find all .arb files in the current directory and subdirectories
      find('*.arb', recursive: true).forEach((file) {
        filePaths.add(file);
      });
    }

    if (filePaths.isEmpty) {
      print(yellow('No .arb files found to update.'));
      return;
    }

    for (var filePath in filePaths) {
      var file = File(filePath);
      if (!await file.exists()) {
        print(red('ERROR! File does not exist: $filePath.'));
        continue;
      }

      try {
        var arbContent = await file.readAsString();
        var updatedContent = mergeARBs(arbContent, jsonToAdd);
        await file.writeAsString(updatedContent);
        print(green('Updated $filePath'));
      } catch (e) {
        print(red('Error updating $filePath: $e'));
      }
    }
  }
}
