import 'package:custom_lint_builder/custom_lint_builder.dart';
// Import the rule file we will create next
import 'src/hardcoded_text_in_widget_lint.dart';

PluginBase createPlugin() => _ArbUtilsLinter();

class _ArbUtilsLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        HardcodedTextInWidgetLint(),
      ];
}
