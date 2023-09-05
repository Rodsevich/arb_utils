import 'package:arb_utils/src/commands/check.dart';
import 'package:arb_utils/src/commands/generate_meta.dart';
import 'package:arb_utils/src/commands/merge.dart';
import 'package:arb_utils/src/commands/sort.dart';
import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

void main(List<String> args) async {
  final runner = CommandRunner('arb_utils', 'A set of utilities for working with arb files.')
    ..addCommand(GenerateMetaCommand())
    ..addCommand(SortCommand())
    ..addCommand(MergeCommand())
    ..addCommand(CheckCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    print(yellow('Usage exception: ' + e.message));
    print(blue(e.usage));
  } catch (e, st) {
    print(red('Unknown error, please report it: $e $st'));
  }
}
