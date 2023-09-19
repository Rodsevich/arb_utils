import 'package:arb_utils/src/commands/check_duplicated_values.dart';
import 'package:args/command_runner.dart';

class CheckDuplicatesCommand extends Command {
  @override
  String get name => 'checkDuplicates';

  @override
  String get description => 'Check duplicates in the arb files with sub command.';

  CheckDuplicatesCommand() {
    addSubcommand(CheckDuplicatedValuesSubCommand());
  }
}
