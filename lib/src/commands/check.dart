import 'package:arb_utils/src/commands/check_duplicates.dart';
import 'package:args/command_runner.dart';

class CheckCommand extends Command {
  @override
  String get name => 'check';

  @override
  String get description => 'Check the arb files with sub command.';

  CheckCommand() {
    addSubcommand(CheckDuplicatesCommand());
  }
}
